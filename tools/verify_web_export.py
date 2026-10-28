"""Fail CI if a Godot web build is incomplete or configured for threaded hosting.

This checks the exported engine's real files, actual byte counts, WASM and
PCK magic, and the subpath-friendly relative asset references used by Pages.
"""

import json
import re
import sys
from pathlib import Path


def verify(folder: Path) -> None:
    expected = (
        "index.html",
        "index.js",
        "index.wasm",
        "index.pck",
        "index.audio.worklet.js",
        "index.audio.position.worklet.js",
        "index.icon.png",
        "index.apple-touch-icon.png",
        "cover.webp",
        ".nojekyll",
    )
    for name in expected:
        path = folder / name
        if not path.is_file() or path.stat().st_size == 0 and name != ".nojekyll":
            raise SystemExit(f"Missing or empty exported asset: {path}")
    html = (folder / "index.html").read_text(encoding="utf-8")
    if "const GODOT_THREADS_ENABLED = false" not in html:
        raise SystemExit("Threaded Web export will not load on ordinary GitHub Pages")
    if "name=\"jianghu-web-shell\"" not in html:
        raise SystemExit("The branded responsive Web shell was not applied")
    if '<script src="index.js"></script>' not in html:
        raise SystemExit("Godot loader is not referenced relatively")
    if re.search(r'<script[^>]*src="https?://', html):
        raise SystemExit("Unexpected remote script in web release")
    config_match = re.search(r'const GODOT_CONFIG = (\{[^\n]+\});', html)
    if config_match is None:
        raise SystemExit("Missing Godot WebAssembly boot configuration")
    config = json.loads(config_match.group(1))
    if config.get("executable") != "index":
        raise SystemExit("Godot executable basename must stay index on Pages")
    for filename, declared_size in config["fileSizes"].items():
        real_size = (folder / filename).stat().st_size
        if real_size != declared_size:
            raise SystemExit(f"Export corruption: {filename} is {real_size} bytes, declared {declared_size}")
    if (folder / "index.wasm").read_bytes()[:4] != b"\x00asm":
        raise SystemExit("WebAssembly file has a corrupted header")
    if (folder / "index.pck").read_bytes()[:4] != b"GDPC":
        raise SystemExit("Godot content pack has a corrupted header")
    print("Jianghu Web release: all assets, sizes, paths, MIME signatures, and thread mode valid")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: verify_web_export.py path/to/build")
    verify(Path(sys.argv[1]))
