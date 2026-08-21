import copy
import unittest

from scripts import fetch_weather_cache as weather


def valid_payload():
    hourly = {
        "id": "2026-08-21T08:00",
        "timeLabel": "8時",
        "weatherCode": 1,
        "temperatureCelsius": 26,
        "apparentTemperatureCelsius": None,
        "condition": "くもり",
        "humidityPercent": 91,
        "precipitationProbabilityPercent": 0,
        "precipitationMillimeters": 0.0,
        "windSpeedKmh": 4,
    }
    weekly = [
        {
            "id": f"2026-08-{day:02d}",
            "dateLabel": f"8/{day}（金）",
            "weatherCode": 1,
            "minTemperatureCelsius": 24,
            "maxTemperatureCelsius": 29,
            "condition": "くもり",
            "humidityPercent": 85,
            "precipitationProbabilityPercent": 10,
        }
        for day in range(21, 28)
    ]
    return {
        "updatedAt": "2026-08-21T08:35:15+09:00",
        "temperatureCelsius": 26,
        "apparentTemperatureCelsius": None,
        "weatherCode": 1,
        "condition": "くもり",
        "humidityPercent": 91,
        "windSpeedKmh": 5,
        "currentWaveHeightMeters": None,
        "todayMaxWaveHeightMeters": None,
        "todayHourlyForecast": [hourly],
        "weeklyForecast": weekly,
    }


class ValidateWeatherPayloadTests(unittest.TestCase):
    def test_accepts_valid_payload_with_optional_nulls(self):
        weather.validate_weather_payload("aijima", valid_payload())

    def test_rejects_invalid_timestamp(self):
        payload = valid_payload()
        payload["updatedAt"] = "2026/08/21"

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)

    def test_rejects_invalid_numeric_range(self):
        payload = valid_payload()
        payload["humidityPercent"] = 101

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)

    def test_accepts_unknown_weather_code_as_unknown_condition(self):
        payload = valid_payload()
        payload["todayHourlyForecast"][0]["weatherCode"] = 86
        payload["todayHourlyForecast"][0]["condition"] = "不明"

        weather.validate_weather_payload("aijima", payload)

    def test_rejects_missing_hourly_forecast(self):
        payload = valid_payload()
        payload["todayHourlyForecast"] = []

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)

    def test_accepts_weekly_forecast_with_six_days(self):
        payload = valid_payload()
        payload["weeklyForecast"].pop()

        weather.validate_weather_payload("aijima", payload)

    def test_rejects_empty_weekly_forecast(self):
        payload = valid_payload()
        payload["weeklyForecast"] = []

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)


def complete_forecast(*, precipitation_probabilities=None, daily_precipitation=None):
    if precipitation_probabilities is None:
        precipitation_probabilities = [0, 10]
    if daily_precipitation is None:
        daily_precipitation = [10] * 7
    return {
        "current": {
            "temperature_2m": 26.4,
            "apparent_temperature": 27.1,
            "weather_code": 1,
            "relative_humidity_2m": 90,
            "wind_speed_10m": 4.4,
        },
        "hourly": {
            "time": ["2026-08-21T08:00", "2026-08-21T09:00"],
            "temperature_2m": [26.0, 27.0],
            "apparent_temperature": [27.0, 28.0],
            "weather_code": [1, 0],
            "precipitation_probability": precipitation_probabilities,
            "relative_humidity_2m": [90, 80],
            "wind_speed_10m": [4.0, 5.0],
            "precipitation": [0.0, 0.2],
        },
        "daily": {
            "time": [f"2026-08-{day:02d}" for day in range(21, 28)],
            "weather_code": [1] * 7,
            "temperature_2m_max": [29.0] * 7,
            "temperature_2m_min": [24.0] * 7,
            "relative_humidity_2m_mean": [85.0] * 7,
            "precipitation_probability_max": daily_precipitation,
        },
    }


class BuildWeatherPayloadTests(unittest.TestCase):
    def test_builds_payload_from_complete_source_data(self):
        forecast = complete_forecast()
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(payload["temperatureCelsius"], 26)
        self.assertEqual(len(payload["todayHourlyForecast"]), 2)
        self.assertEqual(len(payload["weeklyForecast"]), 7)

    def test_treats_null_precipitation_probability_as_zero(self):
        forecast = complete_forecast(precipitation_probabilities=[None, 20])
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(payload["todayHourlyForecast"][0]["precipitationProbabilityPercent"], 0)
        self.assertEqual(payload["todayHourlyForecast"][1]["precipitationProbabilityPercent"], 20)

    def test_treats_null_daily_precipitation_probability_as_zero(self):
        forecast = complete_forecast(daily_precipitation=[None] + [10] * 6)
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(payload["weeklyForecast"][0]["precipitationProbabilityPercent"], 0)

    def test_rejects_non_numeric_precipitation_probability(self):
        forecast = complete_forecast(precipitation_probabilities=["unknown", 10])

        with self.assertRaises(ValueError):
            weather.build_weather_payload(
                forecast,
                None,
                "2026-08-21T08:35:15+09:00",
                weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00"),
            )

    def test_rejects_missing_current_temperature(self):
        forecast = {
            "current": {
                "weather_code": 1,
                "relative_humidity_2m": 90,
                "wind_speed_10m": 4,
            },
            "hourly": {},
            "daily": {},
        }

        with self.assertRaises(ValueError):
            weather.build_weather_payload(
                forecast,
                None,
                "2026-08-21T08:35:15+09:00",
                weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00"),
            )

    def test_rejects_missing_current_weather_code(self):
        forecast = complete_forecast()
        del forecast["current"]["weather_code"]

        with self.assertRaises(ValueError):
            weather.build_weather_payload(
                forecast,
                None,
                "2026-08-21T08:35:15+09:00",
                weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00"),
            )

    def test_treats_null_humidity_and_wind_as_zero(self):
        forecast = complete_forecast()
        forecast["current"]["relative_humidity_2m"] = None
        forecast["current"]["wind_speed_10m"] = None
        forecast["hourly"]["relative_humidity_2m"] = [None, 80]
        forecast["hourly"]["wind_speed_10m"] = [None, 5.0]
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(payload["humidityPercent"], 0)
        self.assertEqual(payload["windSpeedKmh"], 0)
        self.assertEqual(payload["todayHourlyForecast"][0]["humidityPercent"], 0)
        self.assertEqual(payload["todayHourlyForecast"][0]["windSpeedKmh"], 0)

    def test_maps_unknown_weather_code_to_unknown_condition(self):
        forecast = complete_forecast()
        forecast["current"]["weather_code"] = 86
        forecast["hourly"]["weather_code"] = [86, 0]
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(payload["weatherCode"], 86)
        self.assertEqual(payload["condition"], "不明")
        self.assertEqual(payload["todayHourlyForecast"][0]["condition"], "不明")

    def test_truncates_weekly_forecast_to_seven_days(self):
        forecast = complete_forecast()
        forecast["daily"]["time"].append("2026-08-28")
        forecast["daily"]["weather_code"].append(1)
        forecast["daily"]["temperature_2m_max"].append(29.0)
        forecast["daily"]["temperature_2m_min"].append(24.0)
        forecast["daily"]["relative_humidity_2m_mean"].append(85.0)
        forecast["daily"]["precipitation_probability_max"].append(10)
        now = weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00")

        payload = weather.build_weather_payload(
            forecast,
            None,
            "2026-08-21T08:35:15+09:00",
            now,
        )

        weather.validate_weather_payload("aijima", payload)
        self.assertEqual(len(payload["weeklyForecast"]), 7)

    def test_rejects_mismatched_hourly_source_arrays(self):
        forecast = {
            "current": {
                "temperature_2m": 26,
                "weather_code": 1,
                "relative_humidity_2m": 90,
                "wind_speed_10m": 4,
            },
            "hourly": {
                "time": ["2026-08-21T09:00"],
                "temperature_2m": [],
                "apparent_temperature": [26],
                "weather_code": [1],
                "precipitation_probability": [0],
                "relative_humidity_2m": [90],
                "wind_speed_10m": [4],
                "precipitation": [0],
            },
            "daily": {},
        }

        with self.assertRaises(ValueError):
            weather.build_weather_payload(
                copy.deepcopy(forecast),
                None,
                "2026-08-21T08:35:15+09:00",
                weather.datetime.fromisoformat("2026-08-21T08:35:15+09:00"),
            )


class FetchJsonRetryTests(unittest.TestCase):
    def test_retries_then_succeeds(self):
        from unittest.mock import MagicMock, patch

        good = MagicMock()
        good.read.return_value = b'{"ok": true}'
        good.__enter__.return_value = good
        good.__exit__.return_value = False
        error = weather.urllib.error.URLError("timed out")

        with patch("scripts.fetch_weather_cache.urllib.request.urlopen", side_effect=[error, error, good]):
            with patch("scripts.fetch_weather_cache.time.sleep"):
                data = weather.fetch_json("https://example.invalid/forecast")

        self.assertEqual(data, {"ok": True})

    def test_raises_after_all_attempts_fail(self):
        from unittest.mock import patch

        error = weather.urllib.error.URLError("timed out")
        with patch("scripts.fetch_weather_cache.urllib.request.urlopen", side_effect=error):
            with patch("scripts.fetch_weather_cache.time.sleep"):
                with self.assertRaises(RuntimeError):
                    weather.fetch_json("https://example.invalid/forecast")


class StaleCacheWarningTests(unittest.TestCase):
    def test_warns_when_manifest_is_older_than_90_minutes(self):
        import io
        from pathlib import Path
        from tempfile import TemporaryDirectory
        from unittest.mock import patch

        now = weather.datetime.fromisoformat("2026-08-21T12:00:00+09:00")
        with TemporaryDirectory() as tmp:
            path = Path(tmp) / "manifest.json"
            path.write_text('{"updatedAt": "2026-08-21T08:00:00+09:00"}\n', encoding="utf-8")
            stderr = io.StringIO()
            with patch.object(weather, "WEATHER_DIR", Path(tmp)):
                with patch("sys.stderr", stderr):
                    weather.warn_if_existing_cache_is_stale(now)
            self.assertIn("::error::", stderr.getvalue())
            self.assertIn("240 分", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
