#!/bin/bash
# plex定向扫描脚本
# ================= 版本检查 =================
if (( BASH_VERSINFO[0] < 4 )); then
  echo "错误：需要Bash 4.0及以上版本，当前版本：${BASH_VERSION}"
  exit 1
fi

# ================= 配置区域 =================
PLEX_URL="127.0.0.1"   # Plex服务器地址
PLEX_TOKEN="token"       # 有效Token

declare -A LIBRARY_MAP
LIBRARY_MAP=(                            # 媒体库名称与ID映射
  ["动画电影"]=4
  ["华语电影"]=5
)

# ================= 函数定义 =================
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $1"
}

normalize_path() {
  #local path="$(realpath -m "$1")"
  #echo "$path" | sed 's/ /\\ /g'
  realpath -m "$1"
}

generate_plex_path() {
  local raw_path=$(normalize_path "$1")
  # 使用单层URL编码
  plex_path=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$raw_path'))")
  log "ℹ️ 路径编码转换：\n原始路径：$raw_path\n编码路径：$plex_path"
}

send_scan_request() {
  local library_id="$1"
  local plex_path="$2"
  
  local full_url="$PLEX_URL/library/sections/$library_id/refresh?X-Plex-Token=$PLEX_TOKEN&path=$plex_path"
  log "ℹ️ 请求URL（脱敏）: ${full_url//$PLEX_TOKEN/[TOKEN_REDACTED]}"
  
  local response_file=$(mktemp)
  local http_code=$(curl -o "$response_file" -w "%{http_code}" -sS --connect-timeout 20 "$full_url")
  
  if [ "$http_code" -eq 200 ]; then
    log "✅ 扫描请求成功"
  else
    log "❌ 请求失败，HTTP状态码: $http_code"
    log "📄 响应内容: $(cat "$response_file")"
    exit 1
  fi
  rm -f "$response_file"
}

main() {
  log "================ 扫描开始 ================"
  
  if [ $# -ne 2 ]; then
    log "❌ 错误：使用方法: $0 <媒体库名称> <媒体路径>"
    exit 1
  fi
  
  local library_name="$1"
  local media_path="$2"
  
  if [[ ! -v LIBRARY_MAP["$library_name"] ]]; then
    log "❌ 错误：媒体库 '$library_name' 未配置"
    exit 1
  fi
  local library_id=${LIBRARY_MAP["$library_name"]}
  
  generate_plex_path "$media_path"
  send_scan_request "$library_id" "$plex_path"
  
  log "================ 扫描结束 ================"
}

main "$@"

