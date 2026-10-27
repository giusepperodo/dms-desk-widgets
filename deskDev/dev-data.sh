#!/usr/bin/env bash
docker_json=$(docker ps --format '{{json .}}' 2>/dev/null | jq -sc '[.[] | {name: .Names, status: .Status}] | sort_by(.name)' 2>/dev/null)
[ -z "$docker_json" ] && docker_json='[]'

vpn_name=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="vpn"{print $1; exit}')
vpn_ip=$(ip -4 -o addr show ppp0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
if [ -z "$vpn_name" ] && pgrep -x openfortivpn >/dev/null; then
  vpn_name="openfortivpn"
fi

config="$HOME/.config/desk-widgets/config.env"
[ -f "$config" ] && . "$config"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projetos}"

git_json=$(for repo in $GIT_REPOS; do
  dir="$PROJECTS_DIR/$repo"
  [ -d "$dir/.git" ] || continue
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l)
  jq -nc --arg r "$repo" --arg b "${branch:-(detached)}" --argjson c "$changes" '{repo: $r, branch: $b, changes: $c}'
done | jq -sc '.')

cache="$HOME/.cache/desk-widgets/claude.env"
script="$HOME/.config/DankMaterialShell/plugins/claudeCodeUsage/get-claude-usage"
mkdir -p "$(dirname "$cache")"
if [ ! -f "$cache" ] || [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -gt 240 ]; then
  [ -x "$script" ] && "$script" 2>/dev/null | grep -E '^(FIVE_HOUR|SEVEN_DAY)' > "$cache.tmp" && mv "$cache.tmp" "$cache"
fi
FIVE_HOUR_UTIL=""; SEVEN_DAY_UTIL=""; FIVE_HOUR_RESET=""; SEVEN_DAY_RESET=""
[ -f "$cache" ] && . "$cache"
five_reset=$([ -n "$FIVE_HOUR_RESET" ] && date -d "$FIVE_HOUR_RESET" '+%H:%M')
week_reset=$([ -n "$SEVEN_DAY_RESET" ] && LC_TIME=pt_BR.UTF-8 date -d "$SEVEN_DAY_RESET" '+%a %H:%M')

jq -nc \
  --argjson docker "$docker_json" \
  --arg vpnName "$vpn_name" --arg vpnIp "$vpn_ip" \
  --argjson git "${git_json:-[]}" \
  --arg five "${FIVE_HOUR_UTIL%%.*}" --arg week "${SEVEN_DAY_UTIL%%.*}" \
  --arg fiveReset "$five_reset" --arg weekReset "$week_reset" \
  '{docker: $docker, vpn: {name: $vpnName, ip: $vpnIp}, git: $git,
    claude: {five: ($five | tonumber? // null), week: ($week | tonumber? // null), fiveReset: $fiveReset, weekReset: $weekReset}}'
