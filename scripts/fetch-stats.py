#!/usr/bin/env python3
"""Fetch live project stats for the homepage and write them to _data/live_stats.json (gitignored).

Run before the Jekyll build (CI does this in .github/workflows/build.yaml). Uses GITHUB_TOKEN if set.
Every field is optional: a failed request is logged and skipped, and the script always exits 0, so it
never fails the build. Values are ready-to-render labels with the same keys as _data/stats.yml, which the
templates fall back to for any missing field (or a missing file).

Fields: stars, releases, pulls, latest_version, latest_minor, release_url, contributors [{login, avatar, url}].
"""
import json
import os
import re
import sys
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "_data" / "live_stats.json"
REPO = "rook/rook"
API = "https://api.github.com"
WALL_SIZE = 74  # avatars on the contributor wall (limit in index.html)
TIMEOUT = 20
NON_HUMAN = {"autosupport"}  # not a person, but not marked as a bot by GitHub


def log(msg):
    print(f"fetch-stats: {msg}", file=sys.stderr)


def get(url, github=True):
    headers = {"User-Agent": "rook.github.io-fetch-stats", "Accept": "application/json"}
    if github:
        headers["Accept"] = "application/vnd.github+json"
        token = os.environ.get("GITHUB_TOKEN")
        if token:
            headers["Authorization"] = f"Bearer {token}"
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=TIMEOUT) as r:
        return json.load(r), r.headers


def field(names, fn, data):
    try:
        values = fn()
        if not values:
            raise ValueError("empty value")
        data.update(values if isinstance(values, dict) else {names: values})
    except Exception as e:  # noqa: BLE001 - any failure only drops this field
        log(f"{names}: skipped ({e})")


def stars():
    n = int(get(f"{API}/repos/{REPO}")[0]["stargazers_count"])
    if n < 1000:
        return str(n)
    whole, tenth = divmod(int(n / 100 + 0.5), 10)  # 13697 -> "13.7k", 14000 -> "14k"
    return f"{whole}.{tenth}k" if tenth else f"{whole}k"


def release():
    best = None
    for rel in get(f"{API}/repos/{REPO}/releases?per_page=100")[0]:
        m = re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)", rel.get("tag_name") or "")
        if rel.get("draft") or rel.get("prerelease") or not m:
            continue
        key = tuple(int(x) for x in m.groups())
        if best is None or key > best[0]:
            best = (key, rel["html_url"])
    if best is None:
        return None
    (major, minor, patch), url = best
    return {"latest_version": f"{major}.{minor}.{patch}", "latest_minor": f"{major}.{minor}", "release_url": url}


def releases():
    body, headers = get(f"{API}/repos/{REPO}/releases?per_page=1")
    m = re.search(r'[?&]page=(\d+)>;\s*rel="last"', headers.get("Link") or "")
    n = int(m.group(1)) if m else len(body)
    return f"{n // 10 * 10}+" if n >= 10 else None  # 259 -> "250+"


def pulls():
    n = int(get("https://hub.docker.com/v2/repositories/rook/ceph/", github=False)[0]["pull_count"])
    return f"{n // 10_000_000 * 10}M+" if n >= 10_000_000 else None  # 331633773 -> "330M+"


def contributors():
    people, _ = get(f"{API}/repos/{REPO}/contributors?per_page=100")
    wall = []
    for p in people:
        login = p.get("login") or ""
        if p.get("type") == "Bot" or login.lower().endswith("[bot]") or login.lower() in NON_HUMAN:
            continue
        avatar = p["avatar_url"] + ("&" if "?" in p["avatar_url"] else "?") + "s=80"
        wall.append({"login": login, "avatar": avatar, "url": p["html_url"]})
        if len(wall) == WALL_SIZE:
            break
    return wall


def main():
    data = {}
    field("stars", stars, data)
    field("releases", releases, data)
    field("pulls", pulls, data)
    field("release", release, data)
    field("contributors", contributors, data)
    data["fetched_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    try:
        OUT.parent.mkdir(parents=True, exist_ok=True)
        OUT.write_text(json.dumps(data, indent=2) + "\n")
        log(f"wrote {OUT} ({', '.join(k for k in data if k != 'fetched_at') or 'no fields'})")
    except Exception as e:  # noqa: BLE001
        log(f"could not write {OUT}: {e}")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # noqa: BLE001 - never fail the build
        log(f"unexpected error: {e}")
    sys.exit(0)
