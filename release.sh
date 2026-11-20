#!/usr/bin/env bash
# يجهّز ملف update.json لنسخة جديدة: يحسب SHA-256 ويقرأ رقم النسخة من الـ APK.
# الاستخدام:  ./release.sh path/to/app.apk server/update-ithaa.json "رابط APK بعد الرفع" "ما الجديد"
set -euo pipefail
APK="$1"; JSON="$2"; URL="$3"; NOTES="${4:-}"
BADGING=$(${AAPT:-aapt} dump badging "$APK" | head -1)
VC=$(sed -n "s/.*versionCode='\([0-9]*\)'.*/\1/p" <<<"$BADGING")
VN=$(sed -n "s/.*versionName='\([^']*\)'.*/\1/p" <<<"$BADGING")
SHA=$(sha256sum "$APK" | cut -d' ' -f1)
python3 - "$JSON" "$VC" "$VN" "$URL" "$SHA" "$NOTES" <<'PY'
import json, sys
path, vc, vn, url, sha, notes = sys.argv[1:]
try: d = json.load(open(path, encoding="utf-8"))
except Exception: d = {"minVersionCode": 0}
d.update(versionCode=int(vc), versionName=vn, apkUrl=url, sha256=sha)
if notes: d["notes"] = notes
json.dump(d, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(json.dumps(d, ensure_ascii=False, indent=2))
PY
