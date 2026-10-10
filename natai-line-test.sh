#!/bin/sh
set -eu
VERSION=1.1
MODE=quick
TARGET_FILTER=
TIMEOUT=1
HOPS=8
usage() {
  cat <<'EOF'
NAT VPS 三网线路探测器 (Alpine/Debian, no install required)
用法: natai-line-test.sh [选项]
  --quick       每运营商只测一个目标（默认）
  --full        每运营商测全部目标
  --target NAME 只测指定目标名
  --timeout SEC 单次探测超时，默认 1
  --hops N      最大跳数，默认 8
  --help        显示帮助
EOF
}
die() { echo "错误: $*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }
is_positive_int() { case "$1" in ''|*[!0-9]*|0) return 1 ;; *) return 0 ;; esac; }
while [ "$#" -gt 0 ]; do
  case "$1" in
    --quick) MODE=quick; shift ;;
    --full) MODE=full; shift ;;
    --target) [ "$#" -ge 2 ] || die '--target 需要名称'; TARGET_FILTER=$2; shift 2 ;;
    --timeout) [ "$#" -ge 2 ] || die '--timeout 需要秒数'; is_positive_int "$2" || die '--timeout 必须是正整数'; TIMEOUT=$2; shift 2 ;;
    --hops) [ "$#" -ge 2 ] || die '--hops 需要数字'; is_positive_int "$2" || die '--hops 必须是正整数'; HOPS=$2; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --version) echo "$VERSION"; exit 0 ;;
    *) die "未知选项: $1" ;;
  esac
done
if has apk; then OS=Alpine; elif has apt-get; then OS=Debian; else OS=Linux; fi
if has traceroute; then TRACE=traceroute
elif has busybox && busybox traceroute --help >/dev/null 2>&1; then TRACE=busybox
else TRACE=none; fi
if has curl; then HTTP=curl
elif has wget; then HTTP=wget
else HTTP=none; fi
if ! has awk; then AWK=none; else AWK=awk; fi
printf '%s\n' '=== NAT VPS 三网线路探测器 ==='
printf '系统: %s | traceroute: %s | HTTP: %s | awk: %s | 模式: %s\n' "$OS" "$TRACE" "$HTTP" "$AWK" "$MODE"
printf '本机出口: '
if [ "$HTTP" = curl ]; then curl -4 -fsS --max-time "$TIMEOUT" https://api.ipify.org 2>/dev/null || echo unknown
elif [ "$HTTP" = wget ]; then wget -qO- -T "$TIMEOUT" https://api.ipify.org 2>/dev/null || echo unknown
else echo unknown; fi
echo
TARGETS='电信|电信上海|202.96.209.133
电信|电信广州|14.215.116.1
联通|联通北京|123.125.99.1
联通|联通上海|210.22.70.3
移动|移动北京|111.13.111.1
移动|移动广州|120.232.0.1'
run_trace() {
  label=$1; host=$2
  echo "--- $label ($host) ---"
  if [ "$TRACE" = none ]; then echo '跳数: unavailable (未找到 traceroute/BusyBox traceroute)'; return 0; fi
  if [ "$AWK" = none ]; then echo '跳数: unavailable (未找到 awk，无法整理 traceroute 输出)'; return 0; fi
  if [ "$TRACE" = traceroute ]; then
    traceroute -n -w "$TIMEOUT" -q 1 -m "$HOPS" "$host" 2>&1 | awk '/^[[:space:]]*[0-9]+[[:space:]]/ {print; n++} END {if (!n) print "无响应或被 NAT/防火墙过滤"}'
  else
    busybox traceroute -n -w "$TIMEOUT" -q 1 -m "$HOPS" "$host" 2>&1 | awk '/^[[:space:]]*[0-9]+[[:space:]]/ {print; n++} END {if (!n) print "无响应或被 NAT/防火墙过滤"}'
  fi
}
count=0
seen_carriers=
if [ -n "$TARGET_FILTER" ]; then
  case "$TARGET_FILTER" in
    电信上海|202.96.209.133|电信广州|14.215.116.1|联通北京|123.125.99.1|联通上海|210.22.70.3|移动北京|111.13.111.1|移动广州|120.232.0.1) ;;
    *) die "没有匹配目标: $TARGET_FILTER" ;;
  esac
fi
printf '%s\n' "$TARGETS" | while IFS='|' read -r carrier label host; do
  [ -n "$host" ] || continue
  if [ -n "$TARGET_FILTER" ] && [ "$TARGET_FILTER" != "$label" ] && [ "$TARGET_FILTER" != "$host" ]; then continue; fi
  if [ "$MODE" = quick ] && printf '%s\n' "$seen_carriers" | grep -Fxq "$carrier"; then continue; fi
  count=$((count + 1))
  run_trace "$carrier / $label" "$host"
  seen_carriers="$seen_carriers
$carrier"
done
echo '提示: NAT VPS 可能过滤 ICMP/UDP；“无响应”不等于没有线路。可换 --full 或指定 --target 复测。'
