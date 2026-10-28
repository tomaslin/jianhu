"""Fetch only Godot's official Web templates from the large .tpz archive.

The official 4.7.2 export archive is ~1.2 GB. Its server supports HTTP byte
ranges, and a ZIP central directory can be read without downloading every
mobile/desktop template. This tool downloads only needed ZIP members.

Usage:
    python3 tools/extract_web_templates.py list
    python3 tools/extract_web_templates.py extract /tmp/my-templates
"""

from __future__ import annotations

import io
import re
import sys
import urllib.request
import zipfile
from collections import OrderedDict
from pathlib import Path

ARCHIVE = (
    "https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/"
    "Godot_v4.7.2-stable_export_templates.tpz"
)
BLOCK = 2 * 1024 * 1024


class RangedZip(io.RawIOBase):
    def __init__(self):
        req = urllib.request.Request(ARCHIVE, method="HEAD")
        with urllib.request.urlopen(req, timeout=40) as response:
            self.length = int(response.headers["Content-Length"])
        self.pos = 0
        self.cache: OrderedDict[int, bytes] = OrderedDict()

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.pos

    def seek(self, offset, whence=io.SEEK_SET):
        anchor = {io.SEEK_SET: 0, io.SEEK_CUR: self.pos, io.SEEK_END: self.length}[whence]
        self.pos = max(0, anchor + offset)
        return self.pos

    def _fetch(self, index):
        if index in self.cache:
            self.cache.move_to_end(index)
            return self.cache[index]
        start = index * BLOCK
        end = min(self.length, start + BLOCK) - 1
        req = urllib.request.Request(ARCHIVE, headers={"Range": f"bytes={start}-{end}"})
        with urllib.request.urlopen(req, timeout=90) as response:
            if response.status != 206:
                raise OSError("Server did not honor byte-range request")
            value = response.read()
            content_range = response.headers.get("Content-Range", "")
        if not re.match(rf"bytes {start}-{end}/\d+", content_range):
            raise OSError(f"Wrong range from server: {content_range}")
        self.cache[index] = value
        while len(self.cache) > 3:
            self.cache.popitem(last=False)
        return value

    def read(self, size=-1):
        if self.pos >= self.length:
            return b""
        if size is None or size < 0:
            size = self.length - self.pos
        pending = min(size, self.length - self.pos)
        parts = []
        while pending:
            index = self.pos // BLOCK
            section = self._fetch(index)
            offset = self.pos % BLOCK
            count = min(pending, len(section) - offset)
            if count <= 0:
                raise OSError("Missing archive bytes")
            parts.append(section[offset:offset + count])
            self.pos += count
            pending -= count
        return b"".join(parts)


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "extract"):
        raise SystemExit("Usage: extract_web_templates.py list|extract [directory]")
    archive = RangedZip()
    with zipfile.ZipFile(archive) as source:
        web = [i for i in source.infolist() if "/web" in i.filename or i.filename.endswith("/version.txt")]
        for item in web:
            print(f"{item.filename}: {item.file_size // 1024:,} KiB", flush=True)
        if sys.argv[1] == "list":
            return
        if len(sys.argv) != 3:
            raise SystemExit("Extract mode requires a destination folder")
        destination = Path(sys.argv[2])
        destination.mkdir(parents=True, exist_ok=True)
        for item in web:
            if item.is_dir():
                continue
            name = Path(item.filename).name
            target = destination / name
            if target.exists() and target.stat().st_size == item.file_size:
                print("Already present:", name, flush=True)
                continue
            if name not in {"web_nothreads_release.zip", "web_nothreads_debug.zip", "version.txt"}:
                continue
            print("Extracting:", name, flush=True)
            with source.open(item) as input_stream, target.open("wb") as output:
                while True:
                    chunk = input_stream.read(1024 * 1024)
                    if not chunk:
                        break
                    output.write(chunk)
        print("Done:", destination, flush=True)


if __name__ == "__main__":
    main()
