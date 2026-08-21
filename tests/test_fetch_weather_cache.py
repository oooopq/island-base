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

    def test_rejects_unknown_weather_code(self):
        payload = valid_payload()
        payload["todayHourlyForecast"][0]["weatherCode"] = -1

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)

    def test_rejects_missing_hourly_forecast(self):
        payload = valid_payload()
        payload["todayHourlyForecast"] = []

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)

    def test_rejects_weekly_forecast_not_exactly_seven_days(self):
        payload = valid_payload()
        payload["weeklyForecast"].pop()

        with self.assertRaises(ValueError):
            weather.validate_weather_payload("aijima", payload)


class BuildWeatherPayloadTests(unittest.TestCase):
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


if __name__ == "__main__":
    unittest.main()
