
#!/system/bin/sh
TMP="/storage/emulated/0/keybox.xml"
DST="/data/adb/omk/omkdata/keybox.xml"
TS="$(date +%s)"
URL="https://gist.githubusercontent.com/josefapps/d8b7bb36dc9fdc0a962a4a7e4d8c73a6/raw/keybox.xml?t=$TS"
rm -f "$TMP"
curl -s -L -k \
  -H "Cache-Control: no-cache, no-store, must-revalidate" \
  -H "Pragma: no-cache" \
  -H "Expires: 0" \
  -o "$TMP" "$URL"
mkdir -p "$(dirname "$DST")"
rm -f "$DST"
mv "$TMP" "$DST"
