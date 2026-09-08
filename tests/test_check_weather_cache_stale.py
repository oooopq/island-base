#!/usr/bin/env python3
import json
import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import scripts.check_weather_cache_stale as stale_check


class CheckWeatherCacheStaleTests(unittest.TestCase):
    def test_fresh_cache_returns_zero(self):
        now = datetime.fromisoformat("2026-09-08T10:00:00+09:00")
        updated_at = datetime.fromisoformat("2026-09-08T09:30:00+09:00")
        with TemporaryDirectory() as tmp:
            manifest = Path(tmp) / "manifest.json"
            manifest.write_text(
                json.dumps({"updatedAt": updated_at.isoformat()}),
                encoding="utf-8",
            )
            with patch.object(stale_check, "MANIFEST_PATH", manifest):
                self.assertEqual(
                    stale_check.evaluate_manifest(now),
                    0,
                )

    def test_stale_cache_returns_one(self):
        now = datetime.fromisoformat("2026-09-08T12:00:00+09:00")
        updated_at = datetime.fromisoformat("2026-09-08T09:39:51+09:00")
        with TemporaryDirectory() as tmp:
            manifest = Path(tmp) / "manifest.json"
            manifest.write_text(
                json.dumps({"updatedAt": updated_at.isoformat()}),
                encoding="utf-8",
            )
            with patch.object(stale_check, "MANIFEST_PATH", manifest):
                self.assertEqual(
                    stale_check.evaluate_manifest(now),
                    1,
                )

    def test_missing_manifest_returns_two(self):
        with TemporaryDirectory() as tmp:
            missing = Path(tmp) / "missing.json"
            with patch.object(stale_check, "MANIFEST_PATH", missing):
                self.assertEqual(stale_check.main(), 2)

    def test_invalid_updated_at_returns_two(self):
        with TemporaryDirectory() as tmp:
            manifest = Path(tmp) / "manifest.json"
            manifest.write_text('{"updatedAt": "invalid"}\n', encoding="utf-8")
            with patch.object(stale_check, "MANIFEST_PATH", manifest):
                self.assertEqual(stale_check.main(), 2)

    def test_threshold_is_75_minutes(self):
        now = datetime.fromisoformat("2026-09-08T10:00:00+09:00")
        borderline_fresh = now - timedelta(minutes=74, seconds=59)
        borderline_stale = now - timedelta(minutes=75)
        self.assertFalse(stale_check.is_cache_stale(now, borderline_fresh))
        self.assertTrue(stale_check.is_cache_stale(now, borderline_stale))


if __name__ == "__main__":
    unittest.main()
