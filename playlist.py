#!/usr/bin/env python3
"""يضع ملفات m3u داخل stations.json ويرفع رقم version تلقائيًا.
الاستخدام: python3 playlist.py stations.json file1.m3u [file2.m3u ...]"""
import json, os, re, sys
path, files = sys.argv[1], sys.argv[2:]
d = json.load(open(path, encoding="utf-8"))
pl = d.setdefault("playlists", {})
for f in files:
    name = os.path.basename(f)
    if not re.fullmatch(r"[A-Za-z0-9._-]+\.m3u8?", name):
        sys.exit(f"اسم غير صالح: {name} (حروف إنجليزية وأرقام و - فقط)")
    text = open(f, encoding="utf-8-sig").read().replace("\r\n", "\n")
    if "http" not in text:
        sys.exit(f"الملف فارغ: {name}")
    pl[name] = text
    print(f"✓ {name}: {sum(1 for l in text.splitlines() if l.startswith('http'))} أغنية")
d["version"] = int(d.get("version", 0)) + 1
json.dump(d, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("version →", d["version"])
