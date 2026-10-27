#!/usr/bin/env bash
for f in "$HOME/.config/desk-widgets/config.env" "$HOME/.config/desk-widgets/secrets.env"; do
  [ -f "$f" ] && . "$f"
done
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projetos}"
ci_dir="$PROJECTS_DIR/$CI_REPO"
cache="$HOME/.cache/desk-widgets"
mkdir -p "$cache"

prs=$([ -n "$CI_REPO" ] && cd "$ci_dir" 2>/dev/null && timeout 20 gh pr list --author @me --limit 4 --json number,title,reviewDecision,isDraft 2>/dev/null)
review=$(timeout 20 gh search prs --review-requested=@me --state=open --json number 2>/dev/null | jq 'length' 2>/dev/null)
runs=$([ -n "$CI_REPO" ] && cd "$ci_dir" 2>/dev/null && timeout 20 gh run list --limit 2 --json workflowName,status,conclusion,headBranch,createdAt 2>/dev/null)

linear=null
if [ -n "$LINEAR_API_KEY" ]; then
  linear=$(curl -s --max-time 10 https://api.linear.app/graphql \
    -H "Authorization: $LINEAR_API_KEY" -H "Content-Type: application/json" \
    -d '{"query":"{ viewer { assignedIssues(first: 5, filter: { state: { type: { eq: \"started\" } } }) { nodes { identifier title state { name } } } } }"}' \
    | jq -c '[.data.viewer.assignedIssues.nodes[] | {id: .identifier, title: .title, status: .state.name}]' 2>/dev/null)
  [ -z "$linear" ] && linear=null
fi

signoz=null
if [ -n "$SIGNOZ_API_KEY" ] && [ -n "$SIGNOZ_URL" ]; then
  end=$(date +%s%N); start=$(( end - 3600000000000 ))
  signoz=$(curl -s --max-time 15 "$SIGNOZ_URL/api/v1/services" \
    -H "SIGNOZ-API-KEY: $SIGNOZ_API_KEY" -H "Content-Type: application/json" \
    -d "{\"start\":\"$start\",\"end\":\"$end\",\"tags\":[]}" \
    | jq -c '[.[] | {name: .serviceName, errors: (.numErrors // 0), calls: (.numCalls // 0), rate: (.errorRate // 0)}] | sort_by(-.errors)' 2>/dev/null)
  [ -z "$signoz" ] && signoz=null
fi

jq -nc \
  --argjson prs "${prs:-[]}" --argjson review "${review:-0}" --argjson runs "${runs:-[]}" \
  --argjson linear "$linear" --argjson signoz "$signoz" --arg ciRepo "$CI_REPO" \
  '{prs: $prs, reviewCount: $review, runs: $runs, linear: $linear, signoz: $signoz, ciRepo: $ciRepo}'
