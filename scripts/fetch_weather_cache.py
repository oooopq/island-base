#!/usr/bin/env python3
"""全島の天気を Open-Meteo からバッチ取得し docs/weather/{id}.json を生成する。

移植元: IslandBase/Services/WeatherService.swift
設計: docs/weather-cache-design-ja.md
"""
from __future__ import annotations

import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
LOCATIONS_PATH = Path(__file__).with_name("weather_locations.json")
WEATHER_DIR = ROOT / "docs" / "weather"

FORECAST_URL = "https://api.open-meteo.com/v1/forecast"
MARINE_URL = "https://marine-api.open-meteo.com/v1/marine"
FORECAST_ELEVATION_METERS = 5
FORECAST_MODELS = "jma_seamless"
JST = timezone(timedelta(hours=9))
WEEKDAYS_JA = ("月", "火", "水", "木", "金", "土", "日")
USER_AGENT = "IslandBase-weather-cache/1.0"


def load_locations() -> List[Dict[str, Any]]:
    with LOCATIONS_PATH.open(encoding="utf-8") as file:
        locations = json.load(file)
    if not isinstance(locations, list):
        raise ValueError("weather_locations.json は配列である必要があります")
    return locations


def japanese_condition(code: int) -> str:
    """WMO 天気コード → 日本語（WeatherConditionMapper と同一）"""
    if code == 0:
        return "晴れ"
    if code in (1, 2, 3):
        return "くもり"
    if code in (45, 48):
        return "霧"
    if code in (51, 53, 55):
        return "小雨"
    if code in (61, 63, 65):
        return "雨"
    if code in (71, 73, 75):
        return "雪"
    if code in (80, 81, 82):
        return "にわか雨"
    if code in (95, 96, 99):
        return "雷雨"
    return "不明"


def date_label(date_string: str) -> str:
    """日付ラベル（WeatherDateFormatter.label と同一: M/d（E））"""
    try:
        date = datetime.strptime(date_string, "%Y-%m-%d")
    except ValueError:
        return date_string
    weekday = WEEKDAYS_JA[date.weekday()]
    return f"{date.month}/{date.day}（{weekday}）"


def today_date_prefix(now: datetime) -> str:
    """今日の ISO 時刻プレフィックス（WeatherDateFormatter.todayDatePrefix）"""
    return now.strftime("%Y-%m-%dT")


def parse_open_meteo_hour(time_string: str) -> Optional[datetime]:
    """Open-Meteo の hourly 時刻文字列を JST の datetime に変換"""
    try:
        naive = datetime.strptime(time_string, "%Y-%m-%dT%H:%M")
    except ValueError:
        return None
    return naive.replace(tzinfo=JST)


def start_of_current_hour(now: datetime) -> datetime:
    return now.replace(minute=0, second=0, microsecond=0)


def fetch_json(url: str) -> Any:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            body = response.read()
    except urllib.error.HTTPError as error:
        raise RuntimeError(f"HTTP {error.code}: {url}") from error
    except urllib.error.URLError as error:
        raise RuntimeError(f"ネットワークエラー: {error.reason}") from error

    return json.loads(body)


def build_forecast_url(locations: List[Dict[str, Any]]) -> str:
    latitudes = ",".join(str(item["latitude"]) for item in locations)
    longitudes = ",".join(str(item["longitude"]) for item in locations)
    elevations = ",".join(str(FORECAST_ELEVATION_METERS) for _ in locations)
    params = {
        "latitude": latitudes,
        "longitude": longitudes,
        "current": "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code",
        "hourly": (
            "temperature_2m,apparent_temperature,weather_code,precipitation_probability,"
            "relative_humidity_2m,wind_speed_10m,precipitation"
        ),
        "daily": (
            "weather_code,temperature_2m_max,temperature_2m_min,relative_humidity_2m_mean,"
            "precipitation_probability_max"
        ),
        "forecast_days": "7",
        "timezone": "Asia/Tokyo",
        "elevation": elevations,
        "models": FORECAST_MODELS,
    }
    return f"{FORECAST_URL}?{urllib.parse.urlencode(params)}"


def build_marine_url(locations: List[Dict[str, Any]]) -> str:
    latitudes = ",".join(str(item["latitude"]) for item in locations)
    longitudes = ",".join(str(item["longitude"]) for item in locations)
    params = {
        "latitude": latitudes,
        "longitude": longitudes,
        "current": "wave_height",
        "hourly": "wave_height",
        "forecast_days": "1",
        "timezone": "Asia/Tokyo",
    }
    return f"{MARINE_URL}?{urllib.parse.urlencode(params)}"


def build_today_hourly_forecast(hourly: Dict[str, Any], now: datetime) -> List[Dict[str, Any]]:
    times = hourly.get("time") or []
    temperatures = hourly.get("temperature_2m") or []
    apparent_temperatures = hourly.get("apparent_temperature") or []
    weather_codes = hourly.get("weather_code") or []
    precipitation_probabilities = hourly.get("precipitation_probability") or []
    humidities = hourly.get("relative_humidity_2m") or []
    wind_speeds = hourly.get("wind_speed_10m") or []
    precipitations = hourly.get("precipitation") or []

    safe_count = min(
        len(times),
        len(temperatures),
        len(apparent_temperatures),
        len(weather_codes),
        len(precipitation_probabilities),
        len(humidities),
        len(wind_speeds),
        len(precipitations),
    )

    start_hour = start_of_current_hour(now)
    forecasts: List[Dict[str, Any]] = []

    for index in range(safe_count):
        time_string = times[index]
        slot_date = parse_open_meteo_hour(time_string)
        if slot_date is None or slot_date < start_hour:
            continue

        apparent_value = apparent_temperatures[index]
        apparent_celsius = None
        if apparent_value is not None:
            apparent_celsius = int(round(apparent_value))

        precipitation_prob = precipitation_probabilities[index] or 0
        hour = slot_date.hour

        forecasts.append(
            {
                "id": time_string,
                "timeLabel": f"{hour}時",
                "weatherCode": int(weather_codes[index]),
                "temperatureCelsius": int(round(temperatures[index])),
                "apparentTemperatureCelsius": apparent_celsius,
                "condition": japanese_condition(int(weather_codes[index])),
                "humidityPercent": int(humidities[index]),
                "precipitationProbabilityPercent": max(0, int(precipitation_prob)),
                "precipitationMillimeters": max(0.0, float(precipitations[index])),
                "windSpeedKmh": int(round(wind_speeds[index])),
            }
        )

        if len(forecasts) >= 24:
            break

    return forecasts


def build_weekly_forecast(daily: Dict[str, Any]) -> List[Dict[str, Any]]:
    times = daily.get("time") or []
    weather_codes = daily.get("weather_code") or []
    max_temperatures = daily.get("temperature_2m_max") or []
    min_temperatures = daily.get("temperature_2m_min") or []
    mean_humidities = daily.get("relative_humidity_2m_mean") or []
    precipitation_max = daily.get("precipitation_probability_max") or []

    safe_count = min(
        len(times),
        len(weather_codes),
        len(max_temperatures),
        len(min_temperatures),
        len(mean_humidities),
        len(precipitation_max),
    )

    weekly: List[Dict[str, Any]] = []
    for index in range(safe_count):
        weekly.append(
            {
                "id": times[index],
                "dateLabel": date_label(times[index]),
                "weatherCode": int(weather_codes[index]),
                "minTemperatureCelsius": int(round(min_temperatures[index])),
                "maxTemperatureCelsius": int(round(max_temperatures[index])),
                "condition": japanese_condition(int(weather_codes[index])),
                "humidityPercent": int(round(mean_humidities[index])),
                "precipitationProbabilityPercent": max(0, int(precipitation_max[index] or 0)),
            }
        )
    return weekly


def build_wave_height_data(marine_entry: Optional[Dict[str, Any]], now: datetime) -> Tuple[Optional[float], Optional[float]]:
    if not marine_entry:
        return None, None

    current = marine_entry.get("current") or {}
    current_wave = current.get("wave_height")

    hourly = marine_entry.get("hourly") or {}
    times = hourly.get("time") or []
    wave_heights = hourly.get("wave_height") or []
    today_prefix = today_date_prefix(now)

    today_values: List[float] = []
    safe_count = min(len(times), len(wave_heights))
    for index in range(safe_count):
        if not str(times[index]).startswith(today_prefix):
            continue
        value = wave_heights[index]
        if value is not None:
            today_values.append(float(value))

    today_max = max(today_values) if today_values else None
    return current_wave, today_max


def build_weather_payload(
    forecast_entry: Dict[str, Any],
    marine_entry: Optional[Dict[str, Any]],
    updated_at: str,
    now: datetime,
) -> Dict[str, Any]:
    current = forecast_entry.get("current") or {}
    hourly = forecast_entry.get("hourly") or {}
    daily = forecast_entry.get("daily") or {}

    apparent_value = current.get("apparent_temperature")
    apparent_celsius = None
    if apparent_value is not None:
        apparent_celsius = int(round(apparent_value))

    current_wave, today_max_wave = build_wave_height_data(marine_entry, now)

    current_weather_code = int(current.get("weather_code", -1))

    return {
        "updatedAt": updated_at,
        "temperatureCelsius": int(round(current.get("temperature_2m", 0))),
        "apparentTemperatureCelsius": apparent_celsius,
        "weatherCode": current_weather_code,
        "condition": japanese_condition(current_weather_code),
        "humidityPercent": int(current.get("relative_humidity_2m", 0)),
        "windSpeedKmh": int(round(current.get("wind_speed_10m", 0))),
        "currentWaveHeightMeters": current_wave,
        "todayMaxWaveHeightMeters": today_max_wave,
        "todayHourlyForecast": build_today_hourly_forecast(hourly, now),
        "weeklyForecast": build_weekly_forecast(daily),
    }


def validate_weather_payload(island_id: str, payload: Dict[str, Any]) -> None:
    """全島検証。1島でも不合格なら例外（Actions 失敗時ポリシーと同じ）"""
    required_keys = (
        "updatedAt",
        "temperatureCelsius",
        "weatherCode",
        "condition",
        "humidityPercent",
        "windSpeedKmh",
        "todayHourlyForecast",
        "weeklyForecast",
    )
    for key in required_keys:
        if key not in payload:
            raise ValueError(f"{island_id}: 必須キー {key} がありません")

    if not payload["condition"]:
        raise ValueError(f"{island_id}: condition が空です")

    if not isinstance(payload.get("weatherCode"), int):
        raise ValueError(f"{island_id}: weatherCode が不正です")

    if not isinstance(payload["todayHourlyForecast"], list):
        raise ValueError(f"{island_id}: todayHourlyForecast が配列ではありません")

    if not isinstance(payload["weeklyForecast"], list) or len(payload["weeklyForecast"]) < 1:
        raise ValueError(f"{island_id}: weeklyForecast が空です")

    for index, slot in enumerate(payload["todayHourlyForecast"]):
        if not isinstance(slot.get("weatherCode"), int):
            raise ValueError(f"{island_id}: todayHourlyForecast[{index}] の weatherCode が不正です")

    for index, day in enumerate(payload["weeklyForecast"]):
        if not isinstance(day.get("weatherCode"), int):
            raise ValueError(f"{island_id}: weeklyForecast[{index}] の weatherCode が不正です")

    if payload["condition"] == "不明" and payload.get("temperatureCelsius") == 0:
        raise ValueError(f"{island_id}: 天気データが不正です")


def ensure_response_list(data: Any, api_name: str) -> List[Dict[str, Any]]:
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and data.get("error"):
        reason = data.get("reason", "不明なエラー")
        raise RuntimeError(f"{api_name} エラー: {reason}")
    raise RuntimeError(f"{api_name} のレスポンス形式が不正です")


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as file:
        json.dump(payload, file, ensure_ascii=False, indent=2)
        file.write("\n")


def main() -> int:
    locations = load_locations()
    if len(locations) != 33:
        print(f"警告: 座標は33島想定ですが {len(locations)} 件です", file=sys.stderr)

    now = datetime.now(JST)
    updated_at = now.isoformat(timespec="seconds")

    print("Forecast API を取得中…")
    forecast_data = ensure_response_list(
        fetch_json(build_forecast_url(locations)),
        "Forecast API",
    )
    if len(forecast_data) != len(locations):
        raise RuntimeError(
            f"Forecast の件数不一致: 期待 {len(locations)} / 実際 {len(forecast_data)}"
        )

    print("Marine API を取得中…")
    marine_data = ensure_response_list(
        fetch_json(build_marine_url(locations)),
        "Marine API",
    )
    if len(marine_data) != len(locations):
        raise RuntimeError(
            f"Marine の件数不一致: 期待 {len(locations)} / 実際 {len(marine_data)}"
        )

    payloads: Dict[str, Dict[str, Any]] = {}
    failures: List[str] = []

    for index, location in enumerate(locations):
        island_id = location["id"]
        try:
            payload = build_weather_payload(
                forecast_data[index],
                marine_data[index],
                updated_at,
                now,
            )
            validate_weather_payload(island_id, payload)
            payloads[island_id] = payload
        except (ValueError, TypeError, KeyError) as error:
            failures.append(f"{island_id}: {error}")

    if failures:
        print("検証失敗（docs/weather は更新しません）:", file=sys.stderr)
        for message in failures:
            print(f"  - {message}", file=sys.stderr)
        return 1

    WEATHER_DIR.mkdir(parents=True, exist_ok=True)
    for island_id, payload in payloads.items():
        write_json(WEATHER_DIR / f"{island_id}.json", payload)

    manifest = {
        "updatedAt": updated_at,
        "islandCount": len(payloads),
        "islands": sorted(payloads.keys()),
    }
    write_json(WEATHER_DIR / "manifest.json", manifest)

    print(f"完了: {len(payloads)} 島の JSON を {WEATHER_DIR} に書き込みました")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"エラー: {error}", file=sys.stderr)
        raise SystemExit(1)
