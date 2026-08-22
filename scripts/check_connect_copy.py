#!/usr/bin/env python3
"""Fail if App Store Connect copy or Info.plist settings drift from the 2026-08-21 submit sheet."""

from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    errors: list[str] = []

    legal = (ROOT / "IslandBase/Utilities/AppLegalInfo.swift").read_text()
    if "oooopq.github.io/island-base" not in legal:
        errors.append("AppLegalInfo must use oooopq.github.io/island-base")
    if "opaquu.github.io" in legal:
        errors.append("AppLegalInfo must not use opaquu.github.io")

    pbx = (ROOT / "IslandBase.xcodeproj/project.pbxproj").read_text()
    if "NSPhotoLibraryUsageDescription" in pbx:
        errors.append("Unused NSPhotoLibraryUsageDescription still in pbxproj")
    if "developmentRegion = ja;" not in pbx:
        errors.append("developmentRegion must be ja")
    if "NSCameraUsageDescription" not in pbx or "NSLocationWhenInUseUsageDescription" not in pbx:
        errors.append("Camera and when-in-use location purpose strings must remain")

    if not (ROOT / "IslandBase/ja.lproj/InfoPlist.strings").exists():
        errors.append("Missing ja.lproj/InfoPlist.strings")
    en = (ROOT / "IslandBase/en.lproj/InfoPlist.strings").read_text()
    ja = (ROOT / "IslandBase/ja.lproj/InfoPlist.strings").read_text()
    for label, text in (("en", en), ("ja", ja)):
        if "NSPhotoLibraryUsageDescription" in text:
            errors.append(f"{label} InfoPlist.strings still has photo library usage")
        if "NSCameraUsageDescription" not in text:
            errors.append(f"{label} InfoPlist.strings missing camera usage")

    copy = (ROOT / "docs/connect-submit-copy-ja.md").read_text()
    for needle in (
        "https://oooopq.github.io/island-base/privacy-policy.html",
        "収集するデータタイプはありません",
        "八重山諸島の船便のみ",
        "WBGT・熱中症指数など未実装",
        "小浜島",
        "鳩間島",
        "PHPicker",
        "Yonaguni",
        "opaquu@gmail.com",
    ):
        if needle not in copy:
            errors.append(f"connect-submit-copy-ja.md missing: {needle}")
    if "https://opaquu.github.io" in copy:
        errors.append("connect-submit-copy-ja.md must not recommend opaquu.github.io")

    html = (ROOT / "docs/privacy-policy.html").read_text()
    if 'id="en"' not in html:
        errors.append("privacy-policy.html needs an English section")
    if "PHPicker" not in html:
        errors.append("privacy-policy.html should describe PHPicker")

    if errors:
        print("FAIL")
        for item in errors:
            print("-", item)
        return 1
    print("PASS connect copy / Info.plist checks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
