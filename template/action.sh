#!/system/bin/sh
echo "正在生成injector.toml 配置..."

DIR="/data/adb/omk/omkdata"
mkdir -p "$DIR"

T="$DIR/injector.tmp"
OUT="$DIR/injector.toml"

BASE_SCOOP_RAW="com.android.vending
com.google.android.gms
com.google.android.gsf
com.eltavine.duckdetector
io.github.vvb2060.keyattestation
io.github.vvb2060.mahoshojo
icu.nullptr.nativetest
com.reveny.nativecheck
com.zhenxi.hunter
io.github.qwq233.keyattestation
com.android.nativetest
io.liankong.riskdetector
luna.safe.luna"

EXCLUDE_PATTERN="lsposed|xposed|thanos|hma_oss|window.hook|vtools|databackup"
THIRD_PARTY=$(pm list packages -3 2>/dev/null | sed 's/^package://' | grep -v -E "$EXCLUDE_PATTERN")

ALL_SCOOP=$(printf "%s\n%s" "$BASE_SCOOP_RAW" "$THIRD_PARTY" | sort -u | grep -v '^$')

cat > "$T" <<'EOF'
# With `[filter].enabled = true`, a UID is intercepted when any package
# sharing that UID is listed in `scoop`.
# Filter deny settings still apply to every package resolved for the UID.

version = 1

scoop = [
EOF

echo "$ALL_SCOOP" | sed 's/^/  "/;s/$/",/' >> "$T"

cat >> "$T" <<'EOF'
]

[main]
enabled = true
log_level = "off"

[filter]
enabled = true
deny_packages = []
block_android_package = true
allow_unknown_package = false

[intercept]
get_security_level = true
get_key_entry = true
update_subcomponent = true
list_entries = true
delete_key = true
grant = true
ungrant = true
get_number_of_entries = true
list_entries_batched = true
get_supplementary_attestation_info = true
EOF

mv "$T" "$OUT"
chmod 644 "$OUT"
chown system:system "$OUT" 2>/dev/null || chown 1000:1000 "$OUT"

echo "✅ 配置生成成功"
