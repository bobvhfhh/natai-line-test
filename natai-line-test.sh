#!/bin/sh
# 河南三网回程线路识别入口，复用 TcpQuality 的 ASN/线路识别逻辑。
set -eu

UPSTREAM="${TCPQUALITY_ENTRY_URL:-https://raw.githubusercontent.com/ibsgss/TcpQuality/main/runTcpQuality.sh}"
MODE=route
DEBUG=0

usage() {
  cat <<'EOF'
河南三网线路检测器（TcpQuality 入口）

默认只检测河南 IPv4 三网回程线路，可识别 CN2GIA、9929、4837、CMI/CMIN2 等标签。

一行运行：
  curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh | sh
  curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh | sh -s -- --full

选项：
  --full       线路识别后追加河南节点 TCP 延迟/丢包探测（并发 2、每节点 5 包）
  --debug      保留并输出 TcpQuality 调试信息
  --help       显示帮助
EOF
}

for arg in "$@"; do
  case "$arg" in
    --full) MODE=full ;;
    --debug) DEBUG=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "错误：不支持参数 $arg" >&2; usage >&2; exit 2 ;;
  esac
done

command -v curl >/dev/null 2>&1 || {
  echo '错误：需要 curl；Alpine 可执行 apk add --no-cache curl bash。' >&2
  exit 1
}
command -v bash >/dev/null 2>&1 || {
  echo '错误：需要 bash；Alpine 可执行 apk add --no-cache bash。' >&2
  exit 1
}

tmp="$(mktemp "${TMPDIR:-/tmp}/natai-tcpquality.XXXXXX")"
trap 'rm -f "$tmp"' EXIT INT TERM
curl -fsSL --retry 2 --connect-timeout 10 --max-time 120 "$UPSTREAM" -o "$tmp"
chmod 700 "$tmp"

printf '%s\n' '=== 河南三网回程线路识别 ==='
printf '%s\n' '线路标签来源：TcpQuality 官方 route/asn 识别接口'
printf '%s\n' '目标：河南 | IPv4 | TCP traceroute'

if [ "$MODE" = route ]; then
  if [ "$DEBUG" -eq 1 ]; then
    exec bash "$tmp" --no-rootfs --province ha -v4 --route --route-protocol tcp --debug
  fi
  exec bash "$tmp" --no-rootfs --province ha -v4 --route --route-protocol tcp
fi

if [ "$DEBUG" -eq 1 ]; then
  exec bash "$tmp" --no-rootfs --province ha -v4 --count 5 --parallel 2 --debug
fi
exec bash "$tmp" --no-rootfs --province ha -v4 --count 5 --parallel 2
