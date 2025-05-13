#!/usr/bin/env python3
"""Download full TTF sets for a list of Google Fonts families.

The script grabs files from the public google/fonts repository (main/ofl/ or
main/apache/).  All .ttf variants and the license file will be copied into
assets/google_fonts/<Family_Name_With_Underscores>/.

Run from the project root:
    python scripts/download_fonts.py
"""
from __future__ import annotations
import re
import json
import pathlib
import urllib.request
from typing import List

FAMILIES: List[str] = [
    "Averia Serif Libre",
    "Alumni Sans",
    "Orbitron",
    "Anaheim",
    "Danfo",
    "Bree Serif",
    "Young Serif",
    "Oxanium",
    "Geist Mono",
    "MuseoModerno",
    "DM Serif Display",
    "Lexend Deca",
    "Pixelify Sans",
    "Gemunu Libre",
    "Podkova",
    "Tourney",
    "Instrument Serif",
    "Tektur",
    "Asap Condensed",
]

GITHUB_API_BASE = "https://api.github.com/repos/google/fonts/contents"
HEADERS = {"Accept": "application/vnd.github.v3.raw"}
DEST_ROOT = pathlib.Path("assets/google_fonts")
DEST_ROOT.mkdir(parents=True, exist_ok=True)


def http_json(url: str):
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read().decode())


def download_file(url: str, dest: pathlib.Path):
    with urllib.request.urlopen(url) as resp, dest.open("wb") as fh:
        fh.write(resp.read())


def slugify(name: str) -> str:
    """google/fonts directory names are lower-case alphanum (spaces removed)."""
    return re.sub(r"[^a-z0-9]", "", name.lower())


def process_family(family: str):
    slug = slugify(family)
    api_path = None
    for repo_dir in ("ofl", "apache"):
        url = f"{GITHUB_API_BASE}/{repo_dir}/{slug}"
        try:
            listing = http_json(url)
            if isinstance(listing, list):
                api_path = url
                break
        except urllib.error.HTTPError:
            pass  # try next directory
    if not api_path:
        print(f"[skip] {family}: not found in google/fonts repo")
        return

    dest_dir = DEST_ROOT / family.replace(" ", "_")
    dest_dir.mkdir(exist_ok=True)

    for item in listing:  # type: ignore[arg-type]
        if item["name"].lower().endswith(".ttf") or item["name"].lower() in ("ofl.txt", "license.txt"):
            dest_path = dest_dir / item["name"]
            if dest_path.exists():
                continue
            print(f"  ↳ {family}: {item['name']}")
            download_file(item["download_url"], dest_path)


def main():
    for fam in FAMILIES:
        print(f"Fetching {fam} …")
        process_family(fam)
    print("✓ All done. Add 'assets/google_fonts/' to pubspec.yaml if not already present.")


if __name__ == "__main__":
    main() 