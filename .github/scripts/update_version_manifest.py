#!/usr/bin/env python3
"""
Among Us Mod Auto Deploy Script (AUMADS)
Version Manifest Auto-Updater

Combines:
1. Steam PICS / News API monitoring for Among Us vanilla releases (hotfix-safe).
2. Mod release note + repository metadata (.csproj / tag structure) inspection.
3. Sanity checks (negative-context guard, version monotonicity, asset URL verification).
4. Updates config/version_manifest.json and optionally syncs AutoDeployTestEnv/config/version_mapping.json when present locally.
"""

from __future__ import annotations

import argparse
import base64
import copy
import datetime as dt
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

STEAM_APP_ID = "945360"
STEAM_DEPOT_ID = "945361"
STEAMCMD_API_URL = f"https://api.steamcmd.net/v1/info/{STEAM_APP_ID}"
STEAM_NEWS_API_URL = (
    f"https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/"
    f"?appid={STEAM_APP_ID}&count=10&maxlength=600&format=json"
)
GITHUB_API_BASE = "https://api.github.com"

NEGATIVE_HINTS = (
    "未対応",
    "非対応",
    "対応していません",
    "対応予定",
    "not compatible",
    "not support",
    "unsupported",
    "incompatible",
    "doesn't work",
    "does not work",
    "do not update",
    "don't update",
)


def http_get_json(url: str, github_token: str | None = None, timeout: int = 15) -> Any:
    """Fetch JSON from an HTTP endpoint with optional GitHub Bearer auth."""
    headers = {"User-Agent": "AUMADS-Manifest-Updater/1.0"}
    if github_token and "api.github.com" in url:
        headers["Authorization"] = f"Bearer {github_token}"
        headers["Accept"] = "application/vnd.github+json"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def http_head_ok(url: str, timeout: int = 15) -> tuple[bool, int | str]:
    """Verify that an asset URL resolves (HTTP 2xx/3xx)."""
    headers = {"User-Agent": "AUMADS-Manifest-Updater/1.0"}
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return (200 <= resp.status < 400, resp.status)
        except urllib.error.HTTPError as e:
            if method == "HEAD" and e.code in (403, 405):
                continue
            return (False, e.code)
        except Exception as e:
            return (False, str(e))
    return (False, "unknown")


def parse_version_tuple(ver_str: str) -> tuple[int, ...] | None:
    """Convert a version string like 'v2026.9.30.0' or '3.3.0.1' into a sortable int tuple."""
    if not ver_str or ver_str == "NONE":
        return None
    cleaned = ver_str.strip().lstrip("vV")
    if not re.fullmatch(r"\d+(?:\.\d+)*", cleaned):
        return None
    return tuple(int(p) for p in cleaned.split("."))


def compare_versions(a: str, b: str) -> int | None:
    """Compare two version strings numerically. Returns -1, 0, 1 or None if non-comparable."""
    ta = parse_version_tuple(a)
    tb = parse_version_tuple(b)
    if ta is None or tb is None:
        return None
    length = max(len(ta), len(tb))
    pa = ta + (0,) * (length - len(ta))
    pb = tb + (0,) * (length - len(tb))
    if pa < pb:
        return -1
    if pa > pb:
        return 1
    return 0


def parse_major_num(major: str | None) -> int | None:
    """Extract integer major number from 'v19' -> 19."""
    if not major:
        return None
    m = re.search(r"(\d+)", major)
    return int(m.group(1)) if m else None


def is_negative_context(text: str, start: int, end: int) -> bool:
    """Check whether the matched version mention is surrounded by negative/unsupported wording."""
    window = text[max(0, start - 60) : min(len(text), end + 80)].lower()
    return any(hint in window for hint in NEGATIVE_HINTS)


def fetch_github_file(
    repo: str, path: str, ref: str, github_token: str | None = None
) -> str | None:
    """Fetch decoded UTF-8 content of a file at a specific git ref/tag."""
    encoded_ref = urllib.parse.quote(ref, safe="")
    url = f"{GITHUB_API_BASE}/repos/{repo}/contents/{path}?ref={encoded_ref}"
    try:
        data = http_get_json(url, github_token=github_token)
        content = data.get("content")
        if content:
            return base64.b64decode(content).decode("utf-8", errors="ignore")
    except Exception:
        return None
    return None


def fetch_steam_state() -> dict[str, Any]:
    """Retrieve public & public-previous depot manifest IDs and latest Steam News major hint."""
    result: dict[str, Any] = {
        "public_manifest_id": None,
        "prev_manifest_id": None,
        "build_id": None,
        "time_updated": None,
        "news_major": None,
        "news_date": None,
    }
    try:
        info = http_get_json(STEAMCMD_API_URL)
        app = info.get("data", {}).get(STEAM_APP_ID, {})
        depots = app.get("depots", {})
        branches = depots.get("branches", {})
        pub_branch = branches.get("public", {})
        depot_manifests = depots.get(STEAM_DEPOT_ID, {}).get("manifests", {})

        result["public_manifest_id"] = depot_manifests.get("public", {}).get("gid")
        result["prev_manifest_id"] = depot_manifests.get("public-previous", {}).get("gid")
        result["build_id"] = pub_branch.get("buildid")
        ts = pub_branch.get("timebuildupdated") or pub_branch.get("timeupdated")
        if ts:
            result["time_updated"] = dt.datetime.fromtimestamp(
                int(ts), tz=dt.timezone.utc
            ).strftime("%Y-%m-%d")
    except Exception as e:
        print(f"[WARN] SteamCMD API fetch failed: {e}")

    try:
        news = http_get_json(STEAM_NEWS_API_URL)
        for item in news.get("appnews", {}).get("newsitems", []):
            combined = f"{item.get('title', '')}\n{item.get('contents', '')}"
            m = re.search(r"(?i)\bUpdate\s+v(\d+)\.\d+\.\d+", combined)
            if m:
                result["news_major"] = f"v{m.group(1)}"
                if item.get("date"):
                    result["news_date"] = dt.datetime.fromtimestamp(
                        int(item["date"]), tz=dt.timezone.utc
                    ).strftime("%Y-%m-%d")
                break
    except Exception as e:
        print(f"[WARN] Steam News API fetch failed: {e}")

    return result


def parse_nos_tag(tag_name: str) -> tuple[str, str] | None:
    """Parse NOS tag like 'v,v3.7.2.1,110,1670' -> (display_tag 'v3.7.2.1', gen '110')."""
    parts = [p.strip() for p in tag_name.split(",")]
    if len(parts) >= 3 and parts[0] == "v" and parts[2].isdigit():
        return (parts[1], parts[2])
    return None


def detect_release_compat(
    mod_id: str,
    repo: str,
    release: dict[str, Any],
    among_us_entries: list[dict[str, Any]],
    github_token: str | None = None,
) -> tuple[str | None, str | None]:
    """
    Determine which Among Us major version (e.g. 'v19') and gameVer (e.g. '2026.9.29')
    a GitHub release targets. Returns (major, gameVer).
    """
    tag = release.get("tag_name", "")
    body = release.get("body") or ""

    if mod_id in ("ER", "ER+ES"):
        m = re.search(
            r"Among\s*Us\s+v(\d+)\s*\(\s*v?(\d{4}\.\d{1,2}\.\d{1,2})\s*\)",
            body,
            flags=re.IGNORECASE,
        )
        if m:
            return (f"v{m.group(1)}", m.group(2))
        csproj = fetch_github_file(
            repo, "ExtremeRoles/ExtremeRoles.csproj", tag, github_token
        )
        if csproj:
            m_suf = re.search(r"<VersionSuffix>AmongUsV(\d+)</VersionSuffix>", csproj)
            m_lib = re.search(
                r'<PackageReference\s+Include="AmongUs\.GameLibs\.Steam"\s+Version="([^"]+)"',
                csproj,
            )
            major = f"v{m_suf.group(1)}" if m_suf else None
            gver = m_lib.group(1) if m_lib else None
            if major or gver:
                return (major, gver)

    elif mod_id == "LM":
        m = re.search(
            r"Among\s*Us\s+(\d{4}\.\d{1,2}\.\d{1,2})\s*\(\s*v(\d+)",
            body,
            flags=re.IGNORECASE,
        )
        if m and not is_negative_context(body, m.start(), m.end()):
            return (f"v{m.group(2)}", m.group(1))
        csproj = fetch_github_file(repo, "LasMonjas/LasMonjas.csproj", tag, github_token)
        if csproj:
            m_gv = re.search(r"<GameVersion>(\d{4}\.\d{1,2}\.\d{1,2})</GameVersion>", csproj)
            if m_gv:
                gver = m_gv.group(1)
                for au in among_us_entries:
                    if au.get("gameVer") == gver:
                        return (au.get("major"), gver)
                return (None, gver)

    elif mod_id == "SNR":
        for m in re.finditer(
            r"(?:Among\s*Us|AmongUs)\s+v(\d+)(?:\.\d+)*\s*(?:に対応|対応|support|compatibility)|"
            r"(?:Support(?:ed|s)?|Updated?\s+(?:to|for)|Compatible\s+with)\s+Among\s*Us\s+v(\d+)",
            body,
            flags=re.IGNORECASE,
        ):
            if not is_negative_context(body, m.start(), m.end()):
                maj = m.group(1) or m.group(2)
                return (f"v{maj}", None)

    elif mod_id == "SRA":
        for m in re.finditer(
            r"(?:Updated?\s+to|Compatible\s+with)\s+Among\s*Us\s+v(\d+)",
            body,
            flags=re.IGNORECASE,
        ):
            if not is_negative_context(body, m.start(), m.end()):
                return (f"v{m.group(1)}", None)

    elif mod_id == "TOH":
        m = re.search(r"(\d+)\.\d+\.\d+より前のバージョンでは使用できません", body)
        if m:
            return (f"v{m.group(1)}", None)

    for au in among_us_entries:
        gver = au.get("gameVer")
        maj = au.get("major")
        if gver:
            m = re.search(re.escape(gver), body)
            if m and not is_negative_context(body, m.start(), m.end()):
                return (maj, gver)
        if maj:
            maj_num = parse_major_num(maj)
            if maj_num is not None:
                m = re.search(rf"\bAmong\s*Us\s+v{maj_num}\b", body, flags=re.IGNORECASE)
                if m and not is_negative_context(body, m.start(), m.end()):
                    return (maj, gver)

    return (None, None)


def fetch_releases(repo: str, github_token: str | None = None, limit: int = 20) -> list[dict[str, Any]]:
    """Fetch non-draft, non-prerelease GitHub releases for a repository."""
    url = f"{GITHUB_API_BASE}/repos/{repo}/releases?per_page={limit}"
    data = http_get_json(url, github_token=github_token)
    if not isinstance(data, list):
        return []
    return [r for r in data if not r.get("draft") and not r.get("prerelease")]


def maybe_update_among_us_section(
    manifest: dict[str, Any],
    steam: dict[str, Any],
    er_hint: tuple[str | None, str | None],
    lm_hint: tuple[str | None, str | None],
) -> list[str]:
    """
    Update manifest['amongUs'] when Steam public manifest changes.
    Only shifts generations (latest -> prev0 -> prev1) when a new major version is detected;
    same-major hotfixes update manifestId/buildId in-place without invalidating mods.
    """
    notes: list[str] = []
    au = manifest["amongUs"]
    latest = au["latest"]
    pub_gid = steam.get("public_manifest_id")
    if not pub_gid:
        notes.append("Steam public manifestId could not be fetched; keeping existing AmongUs info.")
        return notes

    if pub_gid == latest.get("manifestId"):
        if steam.get("build_id") and not latest.get("buildId"):
            latest["buildId"] = str(steam["build_id"])
            notes.append(f"Updated AmongUs latest buildId -> {latest['buildId']}")
        return notes

    cur_major_num = parse_major_num(latest.get("major")) or 0
    candidate_major = steam.get("news_major") or er_hint[0] or lm_hint[0]
    candidate_gver = er_hint[1] or lm_hint[1]
    cand_major_num = parse_major_num(candidate_major) or 0

    is_major_shift = cand_major_num > cur_major_num
    if is_major_shift:
        old_prev1 = copy.deepcopy(au["prev1"])
        if old_prev1 and not any(
            h.get("manifestId") == old_prev1.get("manifestId") for h in au.get("history", [])
        ):
            au.setdefault("history", []).insert(0, old_prev1)

        au["prev1"] = copy.deepcopy(au["prev0"])
        au["prev0"] = copy.deepcopy(latest)

        rel_date = steam.get("news_date") or steam.get("time_updated") or dt.datetime.now(
            dt.timezone.utc
        ).strftime("%Y-%m-%d")
        if not candidate_gver:
            y, m, d = rel_date.split("-")
            candidate_gver = f"{int(y)}.{int(m)}.{int(d)}"

        au["latest"] = {
            "major": f"v{cand_major_num}",
            "gameVer": candidate_gver,
            "manifestId": str(pub_gid),
            "buildId": str(steam.get("build_id") or ""),
            "releaseDate": rel_date,
            "nosGeneration": None,
            "notes": f"Auto-detected Among Us v{cand_major_num}",
        }
        notes.append(
            f"Major Among Us update detected: {latest.get('major')} -> v{cand_major_num} "
            f"(gameVer={candidate_gver}, manifestId={pub_gid})"
        )
    else:
        old_gid = latest.get("manifestId")
        latest["manifestId"] = str(pub_gid)
        if steam.get("build_id"):
            latest["buildId"] = str(steam["build_id"])
        notes.append(
            f"Same-major Among Us manifest updated in-place ({latest.get('major')}): "
            f"{old_gid} -> {pub_gid}"
        )

    return notes


def verify_mod_release_asset(
    mod_id: str,
    version_tag: str,
    releases: list[dict[str, Any]],
) -> tuple[bool, str]:
    """Verify that the target release exists in GitHub releases and its primary asset URL returns HTTP 200/302."""
    if not version_tag or version_tag == "NONE":
        return (True, "NONE (skipped)")

    target_rel = None
    for r in releases:
        tag = r.get("tag_name", "")
        if mod_id == "NOS":
            parsed = parse_nos_tag(tag)
            if parsed and parsed[0] == version_tag:
                target_rel = r
                break
        elif tag == version_tag:
            target_rel = r
            break

    if target_rel is None:
        return (False, f"Release tag '{version_tag}' not found in recent releases")

    assets = target_rel.get("assets") or []
    preferred = [a for a in assets if a.get("name", "").lower().endswith(".zip")]
    if not preferred:
        preferred = assets
    if not preferred:
        return (False, f"No downloadable assets on release '{target_rel.get('tag_name')}'")

    url = preferred[0].get("browser_download_url")
    if not url:
        return (False, "Missing browser_download_url")

    ok, status = http_head_ok(url)
    return (ok, f"HTTP {status} ({preferred[0].get('name')})")


def update_manifest(
    manifest: dict[str, Any],
    github_token: str | None = None,
    verify_urls: bool = False,
) -> tuple[dict[str, Any], list[str], list[str], bool]:
    """Run full manifest update pipeline. Returns (updated_manifest, logs, warnings, major_shifted)."""
    updated = copy.deepcopy(manifest)
    logs: list[str] = []
    warnings: list[str] = []

    au_before_major = updated["amongUs"]["latest"].get("major")
    steam = fetch_steam_state()
    logs.append(
        f"Steam State: public={steam.get('public_manifest_id')} "
        f"prev={steam.get('prev_manifest_id')} news_major={steam.get('news_major')}"
    )

    repo_releases: dict[str, list[dict[str, Any]]] = {}
    for mod_id, cfg in updated["mods"].items():
        if cfg.get("deprecated"):
            continue
        repo = cfg["repo"]
        if repo not in repo_releases:
            try:
                repo_releases[repo] = fetch_releases(repo, github_token=github_token, limit=25)
            except Exception as e:
                warnings.append(f"{mod_id} ({repo}) release fetch failed: {e}")
                repo_releases[repo] = []

    au_entries = [
        updated["amongUs"]["latest"],
        updated["amongUs"]["prev0"],
        updated["amongUs"]["prev1"],
    ]

    er_hint: tuple[str | None, str | None] = (None, None)
    lm_hint: tuple[str | None, str | None] = (None, None)
    er_rels = repo_releases.get(updated["mods"]["ER"]["repo"], [])
    if er_rels:
        er_hint = detect_release_compat("ER", updated["mods"]["ER"]["repo"], er_rels[0], au_entries, github_token)
    lm_rels = repo_releases.get(updated["mods"]["LM"]["repo"], [])
    if lm_rels:
        lm_hint = detect_release_compat("LM", updated["mods"]["LM"]["repo"], lm_rels[0], au_entries, github_token)

    au_logs = maybe_update_among_us_section(updated, steam, er_hint, lm_hint)
    logs.extend(au_logs)

    au_after_major = updated["amongUs"]["latest"].get("major")
    major_shifted = au_after_major != au_before_major
    au_entries = [
        updated["amongUs"]["latest"],
        updated["amongUs"]["prev0"],
        updated["amongUs"]["prev1"],
    ]
    slot_keys = ("latest", "prev0", "prev1")

    for mod_id, cfg in updated["mods"].items():
        if cfg.get("deprecated"):
            continue

        repo = cfg["repo"]
        rels = repo_releases.get(repo, [])
        if not rels:
            continue

        if major_shifted:
            cfg["prev1"] = cfg["prev0"]
            cfg["prev0"] = cfg["latest"]
            if not cfg.get("keepExistingWhenNoNewRelease"):
                cfg["latest"] = "NONE"

        if mod_id == "NOS":
            gen_releases: dict[str, list[tuple[str, str]]] = {}
            for r in rels:
                parsed = parse_nos_tag(r.get("tag_name", ""))
                if parsed:
                    disp_tag, gen = parsed
                    gen_releases.setdefault(gen, []).append((disp_tag, r.get("published_at", "")))

            if gen_releases:
                latest_au = updated["amongUs"]["latest"]
                prev0_gen = parse_major_num(updated["amongUs"]["prev0"].get("nosGeneration")) or 0
                if not latest_au.get("nosGeneration"):
                    newer_gens = sorted(
                        (g for g in gen_releases.keys() if int(g) > prev0_gen),
                        key=lambda x: int(x),
                    )
                    if newer_gens:
                        latest_au["nosGeneration"] = newer_gens[0]
                        logs.append(f"NOS: Detected new generation {newer_gens[0]} for {latest_au['major']}")

                for slot, au in zip(slot_keys, au_entries):
                    target_gen = au.get("nosGeneration")
                    if target_gen and target_gen in gen_releases:
                        if cfg[slot] != target_gen:
                            logs.append(f"NOS.{slot}: {cfg[slot]} -> {target_gen}")
                            cfg[slot] = target_gen
                        if slot == "latest":
                            newest_disp_tag = gen_releases[target_gen][0][0]
                            if cfg.get("fallbackTag") != newest_disp_tag:
                                if verify_urls:
                                    ok, detail = verify_mod_release_asset("NOS", newest_disp_tag, rels)
                                    if not ok:
                                        warnings.append(f"NOS.fallbackTag '{newest_disp_tag}' verify failed ({detail}); skipped.")
                                        continue
                                logs.append(f"NOS.fallbackTag: {cfg.get('fallbackTag')} -> {newest_disp_tag}")
                                cfg["fallbackTag"] = newest_disp_tag
            if verify_urls and cfg.get("fallbackTag"):
                ok, detail = verify_mod_release_asset("NOS", str(cfg["fallbackTag"]), rels)
                if ok:
                    logs.append(f"[VERIFY OK] NOS ({cfg['fallbackTag']}): {detail}")
                else:
                    warnings.append(f"[VERIFY WARN] NOS ({cfg['fallbackTag']}): {detail}")
            continue

        major_to_tags: dict[str, list[str]] = {}
        for r in rels:
            maj, _ = detect_release_compat(mod_id, repo, r, au_entries, github_token)
            if maj:
                major_to_tags.setdefault(maj, []).append(r["tag_name"])

        for slot, au in zip(slot_keys, au_entries):
            maj = au.get("major")
            if not maj:
                continue
            tags = major_to_tags.get(maj, [])
            if not tags:
                continue

            sortable = [t for t in tags if parse_version_tuple(t) is not None]
            if not sortable:
                continue
            sortable.sort(key=lambda t: parse_version_tuple(t) or (0,))
            candidate_min = sortable[0]

            if slot == "latest" and cfg.get("prev0") not in (None, "NONE"):
                cmp = compare_versions(candidate_min, cfg["prev0"])
                if cmp is not None and cmp < 0:
                    warnings.append(
                        f"{mod_id}.latest candidate '{candidate_min}' < prev0 '{cfg['prev0']}'; skipped."
                    )
                    continue

            if cfg.get(slot) != candidate_min:
                if cfg.get(slot) == "NONE" or slot == "latest":
                    if verify_urls:
                        ok, detail = verify_mod_release_asset(mod_id, candidate_min, rels)
                        if not ok:
                            warnings.append(
                                f"{mod_id}.{slot} candidate '{candidate_min}' failed asset verify ({detail}); skipped."
                            )
                            continue
                    logs.append(f"{mod_id}.{slot}: {cfg.get(slot)} -> {candidate_min}")
                    cfg[slot] = candidate_min

        if verify_urls and cfg.get("latest") not in (None, "NONE"):
            ok, detail = verify_mod_release_asset(mod_id, str(cfg["latest"]), rels)
            if ok:
                logs.append(f"[VERIFY OK] {mod_id} ({cfg['latest']}): {detail}")
            else:
                warnings.append(f"[VERIFY WARN] {mod_id} ({cfg['latest']}): {detail}")

    return updated, logs, warnings, major_shifted


def build_test_env_mapping(manifest: dict[str, Any]) -> list[dict[str, Any]]:
    """Convert config/version_manifest.json into AutoDeployTestEnv/config/version_mapping.json format."""
    au = manifest["amongUs"]
    entries: list[dict[str, Any]] = []
    for idx, slot in enumerate(("latest", "prev0", "prev1")):
        item = au.get(slot)
        if not item:
            continue
        entries.append(
            {
                "major": item.get("major"),
                "gameVer": item.get("gameVer"),
                "manifestId": item.get("manifestId"),
                "releaseDate": item.get("releaseDate"),
                "nosGeneration": item.get("nosGeneration"),
                "isLatest": idx == 0,
                "notes": item.get("notes", ""),
            }
        )
    for hist in au.get("history", []):
        entries.append(
            {
                "major": hist.get("major"),
                "gameVer": hist.get("gameVer"),
                "manifestId": hist.get("manifestId"),
                "releaseDate": hist.get("releaseDate"),
                "nosGeneration": hist.get("nosGeneration"),
                "isLatest": False,
                "notes": hist.get("notes", "Historical manifest entry"),
            }
        )
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(description="Update AUMADS version_manifest.json")
    parser.add_argument(
        "--manifest",
        default="config/version_manifest.json",
        help="Path to version_manifest.json",
    )
    parser.add_argument(
        "--test-mapping",
        default="AutoDeployTestEnv/config/version_mapping.json",
        help="Optional local path to AutoDeployTestEnv version_mapping.json",
    )
    parser.add_argument(
        "--verify-urls",
        action="store_true",
        help="Verify release asset download URLs via HTTP",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Run without writing files",
    )
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    mapping_path = Path(args.test_mapping)

    with manifest_path.open("r", encoding="utf-8") as f:
        current = json.load(f)

    github_token = os.environ.get("GITHUB_TOKEN") or None
    updated, logs, warnings, _ = update_manifest(
        current, github_token=github_token, verify_urls=args.verify_urls
    )

    for line in logs:
        print(f"[INFO] {line}")
    for w in warnings:
        print(f"[WARN] {w}")

    current_cmp = copy.deepcopy(current)
    updated_cmp = copy.deepcopy(updated)
    current_cmp.pop("updatedAt", None)
    updated_cmp.pop("updatedAt", None)

    changed = current_cmp != updated_cmp
    if changed:
        updated["updatedAt"] = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        print("[CHANGE] version_manifest.json has updates.")
    else:
        print("[NOOP] No changes detected in version_manifest.json.")

    if not args.dry_run and changed:
        manifest_path.write_text(
            json.dumps(updated, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
        )
        print(f"[WRITE] Updated {manifest_path}")
        if mapping_path.parent.exists():
            mapping_data = build_test_env_mapping(updated)
            mapping_path.write_text(
                json.dumps(mapping_data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
            )
            print(f"[WRITE] Synced {mapping_path}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
