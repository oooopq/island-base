#!/usr/bin/env python3
"""docs/weather/manifest.json の updatedAt が古いか判定する。

exit 0: 新しい（再トリガー不要）
exit 1: 古い（再トリガー推奨）
exit 2: manifest 読み取り・解析エラー
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "docs" / "weather" / "manifest.json"
JST = timezone(timedelta(hours=9))
# 通常更新は30分間隔。1枠欠けても次の監視で拾えるよう 50分で再トリガーする
STALE_TRIGGER_AFTER = timedelta(minutes=50)


def parse_updated_at(text: str) -> Optional[datetime]:
    try:
        parsed = datetime.fromisoformat(text)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        return None
    return parsed


def is_cache_stale(now: datetime, updated_at: datetime, threshold: timedelta = STALE_TRIGGER_AFTER) -> bool:
    return now - updated_at >= threshold


def evaluate_manifest(now: datetime) -> int:
    if not MANIFEST_PATH.exists():
        print(f"manifest が見つかりません: {MANIFEST_PATH}", file=sys.stderr)
        return 2

    try:
        data = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        updated_at = parse_updated_at(str(data["updatedAt"]))
    except (OSError, KeyError, TypeError, ValueError) as error:
        print(f"manifest の読み取りに失敗しました: {error}", file=sys.stderr)
        return 2

    if updated_at is None:
        print("updatedAt が ISO 8601（タイムゾーン付き）ではありません", file=sys.stderr)
        return 2

    age = now - updated_at
    age_minutes = int(age.total_seconds() // 60)

    if is_cache_stale(now, updated_at):
        print(
            f"キャッシュが古いため再トリガーが必要です（{age_minutes} 分経過、"
            f"updatedAt={updated_at.isoformat()}）"
        )
        return 1

    print(f"キャッシュは新しいです（{age_minutes} 分経過、updatedAt={updated_at.isoformat()}）")
    return 0


def main() -> int:
    return evaluate_manifest(datetime.now(JST))


if __name__ == "__main__":
    raise SystemExit(main())
