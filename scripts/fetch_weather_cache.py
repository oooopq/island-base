#!/usr/bin/env python3
"""全島の天気を Open-Meteo からバッチ取得し docs/weather/{id}.json を生成する。

移植元: IslandBase/Services/WeatherService.swift
設計: docs/weather-cache-design-ja.md
"""
from __future__ import annotations

import json
import math
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
VALID_WEATHER_CODES = frozenset((0, 1, 2, 3, 45, 48, 51, 53, 55, 61, 63, 65, 71, 73, 75, 80, 81, 82, 95, 96, 99))


def is_finite_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def require_number(source: Dict[str, Any], key: str, context: str) -> float:
    value = source.get(key)
    if not is_finite_number(value):
        raise ValueError(f"{context}: {key} が数値ではありません")
    return float(value)


def optional_number_or_zero(source: Dict[str, Any], key: str, context: str) -> float:
    """Open-Meteo が null を返す任意数値。欠損は 0、不正型は拒否する。"""
    value = source.get(key)
    if value is None:
        return 0.0
    if not is_finite_number(value):
        raise ValueError(f"{context}: {key} が数値ではありません")
    return float(value)


def require_weather_code(source: Dict[str, Any], key: str, context: str) -> int:
    value = source.get(key)
    if not isinstance(value, int) or isinstance(value, bool) or value not in VALID_WEATHER_CODES:
        raise ValueError(f"{context}: {key} が未対応です")
    return value


def require_list(source: Dict[str, Any], key: str, context: str) -> List[Any]:
    value = source.get(key)
    if not isinstance(value, list):
        raise ValueError(f"{context}: {key} が配列ではありません")
    return value


def require_matching_lengths(values: Dict[str, List[Any]], context: str) -> int:
    lengths = {key: len(value) for key, value in values.items()}
    if len(set(lengths.values())) != 1:
        raise ValueError(f"{context}: 配列件数が不一致です ({lengths})")
    return next(iter(lengths.values()), 0)


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
    arrays = {
        "time": require_list(hourly, "time", "hourly"),
        "temperature_2m": require_list(hourly, "temperature_2m", "hourly"),
        "apparent_temperature": require_list(hourly, "apparent_temperature", "hourly"),
        "weather_code": require_list(hourly, "weather_code", "hourly"),
        "precipitation_probability": require_list(hourly, "precipitation_probability", "hourly"),
        "relative_humidity_2m": require_list(hourly, "relative_humidity_2m", "hourly"),
        "wind_speed_10m": require_list(hourly, "wind_speed_10m", "hourly"),
        "precipitation": require_list(hourly, "precipitation", "hourly"),
    }
    safe_count = require_matching_lengths(arrays, "hourly")
    times = arrays["time"]
    temperatures = arrays["temperature_2m"]
    apparent_temperatures = arrays["apparent_temperature"]
    weather_codes = arrays["weather_code"]
    precipitation_probabilities = arrays["precipitation_probability"]
    humidities = arrays["relative_humidity_2m"]
    wind_speeds = arrays["wind_speed_10m"]
    precipitations = arrays["precipitation"]

    start_hour = start_of_current_hour(now)
    forecasts: List[Dict[str, Any]] = []

    for index in range(safe_count):
        time_string = times[index]
        if not isinstance(time_string, str):
            raise ValueError(f"hourly[{index}]: time が文字列ではありません")
        slot_date = parse_open_meteo_hour(time_string)
        if slot_date is None:
            raise ValueError(f"hourly[{index}]: time がISO日時ではありません")
        if slot_date < start_hour:
            continue

        apparent_value = apparent_temperatures[index]
        apparent_celsius = None
        if apparent_value is not None:
            if not is_finite_number(apparent_value):
                raise ValueError(f"hourly[{index}]: apparent_temperature が数値ではありません")
            apparent_celsius = int(round(apparent_value))

        temperature = require_number({"value": temperatures[index]}, "value", f"hourly[{index}].temperature_2m")
        weather_code = require_weather_code({"value": weather_codes[index]}, "value", f"hourly[{index}].weather_code")
        humidity = require_number({"value": humidities[index]}, "value", f"hourly[{index}].relative_humidity_2m")
        precipitation_prob = optional_number_or_zero(
            {"value": precipitation_probabilities[index]},
            "value",
            f"hourly[{index}].precipitation_probability",
        )
        precipitation = optional_number_or_zero(
            {"value": precipitations[index]},
            "value",
            f"hourly[{index}].precipitation",
        )
        wind_speed = require_number({"value": wind_speeds[index]}, "value", f"hourly[{index}].wind_speed_10m")
        hour = slot_date.hour

        forecasts.append(
            {
                "id": time_string,
                "timeLabel": f"{hour}時",
                "weatherCode": weather_code,
                "temperatureCelsius": int(round(temperature)),
                "apparentTemperatureCelsius": apparent_celsius,
                "condition": japanese_condition(weather_code),
                "humidityPercent": int(humidity),
                "precipitationProbabilityPercent": int(precipitation_prob),
                "precipitationMillimeters": precipitation,
                "windSpeedKmh": int(round(wind_speed)),
            }
        )

        if len(forecasts) >= 24:
            break

    return forecasts


def build_weekly_forecast(daily: Dict[str, Any]) -> List[Dict[str, Any]]:
    arrays = {
        "time": require_list(daily, "time", "daily"),
        "weather_code": require_list(daily, "weather_code", "daily"),
        "temperature_2m_max": require_list(daily, "temperature_2m_max", "daily"),
        "temperature_2m_min": require_list(daily, "temperature_2m_min", "daily"),
        "relative_humidity_2m_mean": require_list(daily, "relative_humidity_2m_mean", "daily"),
        "precipitation_probability_max": require_list(daily, "precipitation_probability_max", "daily"),
    }
    safe_count = require_matching_lengths(arrays, "daily")
    times = arrays["time"]
    weather_codes = arrays["weather_code"]
    max_temperatures = arrays["temperature_2m_max"]
    min_temperatures = arrays["temperature_2m_min"]
    mean_humidities = arrays["relative_humidity_2m_mean"]
    precipitation_max = arrays["precipitation_probability_max"]

    weekly: List[Dict[str, Any]] = []
    for index in range(safe_count):
        if not isinstance(times[index], str):
            raise ValueError(f"daily[{index}]: time が文字列ではありません")
        try:
            datetime.strptime(times[index], "%Y-%m-%d")
        except ValueError as error:
            raise ValueError(f"daily[{index}]: time がISO日付ではありません") from error
        weather_code = require_weather_code({"value": weather_codes[index]}, "value", f"daily[{index}].weather_code")
        max_temperature = require_number({"value": max_temperatures[index]}, "value", f"daily[{index}].temperature_2m_max")
        min_temperature = require_number({"value": min_temperatures[index]}, "value", f"daily[{index}].temperature_2m_min")
        humidity = require_number({"value": mean_humidities[index]}, "value", f"daily[{index}].relative_humidity_2m_mean")
        precipitation = optional_number_or_zero(
            {"value": precipitation_max[index]},
            "value",
            f"daily[{index}].precipitation_probability_max",
        )
        weekly.append(
            {
                "id": times[index],
                "dateLabel": date_label(times[index]),
                "weatherCode": weather_code,
                "minTemperatureCelsius": int(round(min_temperature)),
                "maxTemperatureCelsius": int(round(max_temperature)),
                "condition": japanese_condition(weather_code),
                "humidityPercent": int(round(humidity)),
                "precipitationProbabilityPercent": int(precipitation),
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
    current = forecast_entry.get("current")
    hourly = forecast_entry.get("hourly")
    daily = forecast_entry.get("daily")
    if not isinstance(current, dict):
        raise ValueError("current がオブジェクトではありません")
    if not isinstance(hourly, dict):
        raise ValueError("hourly がオブジェクトではありません")
    if not isinstance(daily, dict):
        raise ValueError("daily がオブジェクトではありません")

    apparent_value = current.get("apparent_temperature")
    apparent_celsius = None
    if apparent_value is not None:
        if not is_finite_number(apparent_value):
            raise ValueError("current.apparent_temperature が数値ではありません")
        apparent_celsius = int(round(apparent_value))

    current_wave, today_max_wave = build_wave_height_data(marine_entry, now)

    current_weather_code = require_weather_code(current, "weather_code", "current")
    temperature = require_number(current, "temperature_2m", "current")
    humidity = require_number(current, "relative_humidity_2m", "current")
    wind_speed = require_number(current, "wind_speed_10m", "current")

    return {
        "updatedAt": updated_at,
        "temperatureCelsius": int(round(temperature)),
        "apparentTemperatureCelsius": apparent_celsius,
        "weatherCode": current_weather_code,
        "condition": japanese_condition(current_weather_code),
        "humidityPercent": int(humidity),
        "windSpeedKmh": int(round(wind_speed)),
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

    updated_at = payload["updatedAt"]
    if not isinstance(updated_at, str):
        raise ValueError(f"{island_id}: updatedAt が文字列ではありません")
    try:
        parsed_updated_at = datetime.fromisoformat(updated_at)
    except ValueError as error:
        raise ValueError(f"{island_id}: updatedAt がISO 8601ではありません") from error
    if parsed_updated_at.tzinfo is None:
        raise ValueError(f"{island_id}: updatedAt にタイムゾーンがありません")

    if not isinstance(payload["condition"], str) or not payload["condition"]:
        raise ValueError(f"{island_id}: condition が空です")

    if not isinstance(payload["weatherCode"], int) or isinstance(payload["weatherCode"], bool) or payload["weatherCode"] not in VALID_WEATHER_CODES:
        raise ValueError(f"{island_id}: weatherCode が不正です")

    validate_number(payload["temperatureCelsius"], f"{island_id}: temperatureCelsius", minimum=-90, maximum=70, integer=True)
    validate_number(payload["humidityPercent"], f"{island_id}: humidityPercent", minimum=0, maximum=100, integer=True)
    validate_number(payload["windSpeedKmh"], f"{island_id}: windSpeedKmh", minimum=0, maximum=400, integer=True)
    validate_optional_number(payload.get("apparentTemperatureCelsius"), f"{island_id}: apparentTemperatureCelsius", minimum=-90, maximum=70, integer=True)
    validate_optional_number(payload.get("currentWaveHeightMeters"), f"{island_id}: currentWaveHeightMeters", minimum=0, maximum=100)
    validate_optional_number(payload.get("todayMaxWaveHeightMeters"), f"{island_id}: todayMaxWaveHeightMeters", minimum=0, maximum=100)

    hourly = payload["todayHourlyForecast"]
    weekly = payload["weeklyForecast"]
    if not isinstance(hourly, list) or not hourly:
        raise ValueError(f"{island_id}: todayHourlyForecast が空です")
    if not isinstance(weekly, list) or len(weekly) != 7:
        raise ValueError(f"{island_id}: weeklyForecast は7件必要です")

    validate_hourly_forecasts(island_id, hourly)
    validate_weekly_forecasts(island_id, weekly)


def validate_number(
    value: Any,
    context: str,
    *,
    minimum: float,
    maximum: float,
    integer: bool = False,
) -> None:
    if not is_finite_number(value) or value < minimum or value > maximum:
        raise ValueError(f"{context} が許容範囲外です")
    if integer and not isinstance(value, int):
        raise ValueError(f"{context} が整数ではありません")


def validate_optional_number(
    value: Any,
    context: str,
    *,
    minimum: float,
    maximum: float,
    integer: bool = False,
) -> None:
    if value is not None:
        validate_number(value, context, minimum=minimum, maximum=maximum, integer=integer)


def validate_hourly_forecasts(island_id: str, forecasts: List[Any]) -> None:
    seen_ids = set()
    for index, slot in enumerate(forecasts):
        context = f"{island_id}: todayHourlyForecast[{index}]"
        if not isinstance(slot, dict):
            raise ValueError(f"{context} がオブジェクトではありません")
        for key in ("id", "timeLabel", "condition"):
            if not isinstance(slot.get(key), str) or not slot[key]:
                raise ValueError(f"{context}: {key} が不正です")
        try:
            parsed_id = datetime.strptime(slot["id"], "%Y-%m-%dT%H:%M")
        except ValueError as error:
            raise ValueError(f"{context}: id がISO日時ではありません") from error
        if slot["id"] in seen_ids:
            raise ValueError(f"{context}: id が重複しています")
        seen_ids.add(slot["id"])
        if not isinstance(slot.get("weatherCode"), int) or isinstance(slot["weatherCode"], bool) or slot["weatherCode"] not in VALID_WEATHER_CODES:
            raise ValueError(f"{context}: weatherCode が不正です")
        validate_number(slot.get("temperatureCelsius"), f"{context}: temperatureCelsius", minimum=-90, maximum=70, integer=True)
        validate_optional_number(slot.get("apparentTemperatureCelsius"), f"{context}: apparentTemperatureCelsius", minimum=-90, maximum=70, integer=True)
        validate_number(slot.get("humidityPercent"), f"{context}: humidityPercent", minimum=0, maximum=100, integer=True)
        validate_number(slot.get("precipitationProbabilityPercent"), f"{context}: precipitationProbabilityPercent", minimum=0, maximum=100, integer=True)
        validate_number(slot.get("precipitationMillimeters"), f"{context}: precipitationMillimeters", minimum=0, maximum=1000)
        validate_number(slot.get("windSpeedKmh"), f"{context}: windSpeedKmh", minimum=0, maximum=400, integer=True)


def validate_weekly_forecasts(island_id: str, forecasts: List[Any]) -> None:
    seen_ids = set()
    for index, day in enumerate(forecasts):
        context = f"{island_id}: weeklyForecast[{index}]"
        if not isinstance(day, dict):
            raise ValueError(f"{context} がオブジェクトではありません")
        for key in ("id", "dateLabel", "condition"):
            if not isinstance(day.get(key), str) or not day[key]:
                raise ValueError(f"{context}: {key} が不正です")
        try:
            datetime.strptime(day["id"], "%Y-%m-%d")
        except ValueError as error:
            raise ValueError(f"{context}: id がISO日付ではありません") from error
        if day["id"] in seen_ids:
            raise ValueError(f"{context}: id が重複しています")
        seen_ids.add(day["id"])
        if not isinstance(day.get("weatherCode"), int) or isinstance(day["weatherCode"], bool) or day["weatherCode"] not in VALID_WEATHER_CODES:
            raise ValueError(f"{context}: weatherCode が不正です")
        validate_number(day.get("minTemperatureCelsius"), f"{context}: minTemperatureCelsius", minimum=-90, maximum=70, integer=True)
        validate_number(day.get("maxTemperatureCelsius"), f"{context}: maxTemperatureCelsius", minimum=-90, maximum=70, integer=True)
        if day["minTemperatureCelsius"] > day["maxTemperatureCelsius"]:
            raise ValueError(f"{context}: 最低気温が最高気温を上回っています")
        validate_number(day.get("humidityPercent"), f"{context}: humidityPercent", minimum=0, maximum=100, integer=True)
        validate_number(day.get("precipitationProbabilityPercent"), f"{context}: precipitationProbabilityPercent", minimum=0, maximum=100, integer=True)


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
    if len(locations) != 35:
        print(f"警告: 座標は35島想定ですが {len(locations)} 件です", file=sys.stderr)

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
