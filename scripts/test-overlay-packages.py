#!/usr/bin/env python3
"""Test whether stable-pinned overlay packages build from unstable nixpkgs.

Usage:
  test-overlay-packages.py [--flake-dir DIR] [--timeout SECS] [--jobs N] [--packages PKG1,PKG2,...] [--json]

Reads the overlay file, extracts stable-pinned package names, tests each
against unstable nixpkgs in parallel, and reports which ones can be unpinned.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path


class Status(str, Enum):
    OK = "ok"
    FAILED = "failed"
    TIMEOUT = "timeout"


@dataclass
class Result:
    package: str
    status: Status
    error: str = ""


def parse_stable_packages(overlay_path: Path) -> list[str]:
    """Extract package names from the inherit (super.stable) block."""
    content = overlay_path.read_text()

    # Match the inherit (super.stable) ... ; block
    match = re.search(
        r"inherit\s*\n?\s*\(super\.stable\)\s*\n(.*?)\s*;",
        content,
        re.DOTALL,
    )
    if not match:
        print("ERROR: Could not find 'inherit (super.stable) ...;' block", file=sys.stderr)
        sys.exit(1)

    block = match.group(1)
    # Extract identifiers, skipping comments
    packages = []
    for line in block.splitlines():
        line = line.strip()
        if line.startswith("#") or not line:
            continue
        # Remove inline comments
        line = re.sub(r"#.*", "", line).strip()
        if line:
            packages.append(line)
    return packages


def test_package(pkg: str, flake_dir: str, timeout: int) -> Result:
    """Test if a package builds from unstable nixpkgs (no overlays)."""
    # First try nix build
    try:
        proc = subprocess.run(
            ["nix", "build", "--inputs-from", flake_dir, f"nixpkgs#{pkg}", "--no-link"],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if proc.returncode == 0:
            return Result(pkg, Status.OK)

        stderr = proc.stderr

        # If it's an attribute set (not a derivation), try eval instead
        if "is not a derivation" in stderr or "is a set" in stderr:
            return test_package_eval(pkg, flake_dir, timeout)

        return Result(pkg, Status.FAILED, error=stderr.strip().split("\n")[-1] if stderr.strip() else "unknown error")

    except subprocess.TimeoutExpired:
        return Result(pkg, Status.TIMEOUT, error=f"build exceeded {timeout}s")


def test_package_eval(pkg: str, flake_dir: str, timeout: int) -> Result:
    """Fallback: test attribute-set packages via nix eval."""
    try:
        proc = subprocess.run(
            [
                "nix", "eval", "--inputs-from", flake_dir,
                f"nixpkgs#{pkg}",
                "--apply", "x: builtins.length (builtins.attrNames x)",
            ],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if proc.returncode == 0:
            return Result(pkg, Status.OK)
        return Result(pkg, Status.FAILED, error=proc.stderr.strip().split("\n")[-1] if proc.stderr.strip() else "unknown error")

    except subprocess.TimeoutExpired:
        return Result(pkg, Status.TIMEOUT, error=f"eval exceeded {timeout}s")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flake-dir", default=os.environ.get("NIXOS_CONFIG_DIR", "/etc/nixos"))
    parser.add_argument("--timeout", type=int, default=300, help="Per-package timeout in seconds")
    parser.add_argument("--jobs", type=int, default=4, help="Parallel build jobs")
    parser.add_argument("--packages", help="Comma-separated list of packages to test (default: all stable-pinned)")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable text")
    args = parser.parse_args()

    overlay_path = Path(args.flake_dir) / "overlays" / "default.nix"
    if not overlay_path.exists():
        print(f"ERROR: {overlay_path} not found", file=sys.stderr)
        sys.exit(1)

    all_packages = parse_stable_packages(overlay_path)

    if args.packages:
        packages = [p.strip() for p in args.packages.split(",")]
        unknown = set(packages) - set(all_packages)
        if unknown:
            print(f"WARNING: packages not in stable overlay: {', '.join(unknown)}", file=sys.stderr)
    else:
        packages = all_packages

    if not packages:
        print("No packages to test.")
        return

    results: list[Result] = []

    if not args.json:
        print(f"Testing {len(packages)} packages against unstable nixpkgs ({args.jobs} parallel jobs)...")
        print()

    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        futures = {
            executor.submit(test_package, pkg, args.flake_dir, args.timeout): pkg
            for pkg in packages
        }
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            if not args.json:
                icon = {"ok": "✓", "failed": "✗", "timeout": "⏱"}[result.status.value]
                line = f"  {icon} {result.package}"
                if result.error:
                    line += f"  ({result.error[:80]})"
                print(line)

    # Sort results by status then name
    results.sort(key=lambda r: (r.status.value, r.package))

    if args.json:
        output = {
            "can_unpin": [r.package for r in results if r.status == Status.OK],
            "must_keep": [r.package for r in results if r.status == Status.FAILED],
            "timed_out": [r.package for r in results if r.status == Status.TIMEOUT],
        }
        print(json.dumps(output, indent=2))
    else:
        can_unpin = [r for r in results if r.status == Status.OK]
        must_keep = [r for r in results if r.status == Status.FAILED]
        timed_out = [r for r in results if r.status == Status.TIMEOUT]

        print()
        print(f"Can unpin ({len(can_unpin)}): {', '.join(r.package for r in can_unpin) or 'none'}")
        print(f"Must keep ({len(must_keep)}): {', '.join(r.package for r in must_keep) or 'none'}")
        if timed_out:
            print(f"Timed out ({len(timed_out)}): {', '.join(r.package for r in timed_out)}")


if __name__ == "__main__":
    main()
