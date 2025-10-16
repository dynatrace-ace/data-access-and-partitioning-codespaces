#!/bin/bash

# --- Fail fast & helper ---
set -euo pipefail
fail() { echo -e "\n[ERROR] $*\n" >&2; return 1 2>/dev/null || exit 1; }




##
# Validate dt tenant
##
# --- Require the var and https scheme ---
: "${DT_TENANT_3RDGEN:?}" || fail "DT_TENANT_3RDGEN is not set"
[[ "$DT_TENANT_3RDGEN" =~ ^https:// ]] || fail "DT_TENANT_3RDGEN must start with https://"

# --- Extract hostname and validate pattern ---
_host="${DT_TENANT_3RDGEN#*://}"; _host="${_host%%/*}"

# Allowed 3rd-gen host patterns:
#  *.sprint.apps.dynatracelabs.com   (sprint labs)
#  *.dev.apps.dynatracelabs.com      (dev labs)
#  *.apps.dynatrace.com              (prod SaaS 3rd-gen)
#  *.live.dynatrace.com              (prod SaaS legacy; drop if you don’t want it)
_allowed_host_regex='^([a-z0-9-]+\.)+(sprint\.apps\.dynatracelabs\.com|dev\.apps\.dynatracelabs\.com|apps\.dynatrace\.com|live\.dynatrace\.com)$'

[[ "$_host" =~ $_allowed_host_regex ]] || fail "$(cat <<EOF
DT_TENANT_3RDGEN host not recognized as a 3rd-gen Dynatrace tenant.
  Provided: $_host
  Expected one of:
    *.sprint.apps.dynatracelabs.com
    *.dev.apps.dynatracelabs.com
    *.apps.dynatrace.com
    *.live.dynatrace.com
Hint (sprint example):
  https://nxk2511h.sprint.apps.dynatracelabs.com
EOF
)"

##
# DT_TENANT NORMALIZATION
##

# Normalize: remove a single trailing slash if present
DT_TENANT_3RDGEN="${DT_TENANT_3RDGEN%/}"

# 2) Clone it as DT_TENANT_3GEN
DT_TENANT_3GEN="$DT_TENANT_3RDGEN"

# 3) Build DT_TENANT by removing the ".apps" segment before dynatracelabs.com
#    Example: https://nxk2511h.sprint.apps.dynatracelabs.com
#          -> https://nxk2511h.sprint.dynatracelabs.com
DT_TENANT="${DT_TENANT_3RDGEN/.apps.dynatracelabs.com/.dynatracelabs.com}"

##
# DT ACCESS TOKEN
##

# Build scopes JSON
read -r -d '' SCOPES_JSON <<'JSON'
[
  "activeGateTokenManagement.create",
  "entities.read",
  "logs.ingest",
  "metrics.ingest",
  "openTelemetryTrace.ingest",
  "settings.read",
  "settings.write",
  "DataExport",
  "ReadConfig",
  "WriteConfig",
  "InstallerDownload"
]
JSON


TOKEN_NAME="monaco-$(date +%Y%m%d-%H%M%S)"
REQ_BODY=$(jq -nc --arg name "$TOKEN_NAME" --argjson scopes "$SCOPES_JSON" '{name:$name, scopes:$scopes}')

# Create token
tmp_resp="$(mktemp)"
http_code=$(
  curl -sS -o "$tmp_resp" -w "%{http_code}" -X POST "$DT_TENANT/api/v2/apiTokens" \
    -H "Authorization: Api-Token $DT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$REQ_BODY"
)

# Expect 201 Created
if [[ "$http_code" != "201" ]]; then
  echo "Failed to create token (HTTP $http_code). Full response:"
  jq . < "$tmp_resp" || cat "$tmp_resp"
fi

MONACO_TOKEN="$(jq -r '.token // empty' < "$tmp_resp")"
rm -f "$tmp_resp"

if [[ -z "${MONACO_TOKEN:-}" ]]; then
  echo "Token was created but secret not returned. Response parsing failed."
fi

DT_INGEST_TOKEN="$MONACO_TOKEN"
DT_OPERATOR_TOKEN="$MONACO_TOKEN"




##
# Validate DT_TOKEN
##
# ---- Validate DT_TOKEN has the right permissions/status ----
: "${DT_TENANT:?DT_TENANT must be set}"
: "${DT_TOKEN:?DT_TOKEN must be set}"

LOOKUP_BODY=$(jq -nc --arg t "$DT_TOKEN" '{token:$t}')

tmp_lookup="$(mktemp)"
http_code_lookup=$(
  curl -sS -o "$tmp_lookup" -w "%{http_code}" -X POST "$DT_TENANT/api/v2/apiTokens/lookup" \
    -H "Authorization: Api-Token $DT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$LOOKUP_BODY"
)

if [[ "$http_code_lookup" != "200" ]]; then
  echo "[ERROR] Token lookup failed (HTTP $http_code_lookup). Response:" >&2
  jq . < "$tmp_lookup" >&2 || cat "$tmp_lookup" >&2
  rm -f "$tmp_lookup"
  return 1 2>/dev/null || exit 1
fi

# Must be enabled
enabled=$(jq -r '.enabled' < "$tmp_lookup")
if [[ "$enabled" != "true" ]]; then
  echo "[ERROR] DT_TOKEN is disabled." >&2
  rm -f "$tmp_lookup"
  return 1 2>/dev/null || exit 1
fi

# Must not be expired (if expirationDate is set)
exp=$(jq -r '.expirationDate // empty' < "$tmp_lookup")
if [[ -n "$exp" ]]; then
  # ISO8601 → epoch (portable with GNU date; on macOS use gdate)
  now_epoch=$(date -u +%s)
  exp_epoch=$(date -u -d "$exp" +%s)
  if (( now_epoch > exp_epoch )); then
    echo "[ERROR] DT_TOKEN is expired (expirationDate=$exp)." >&2
    rm -f "$tmp_lookup"
    return 1 2>/dev/null || exit 1
  fi
fi

# Must include apiTokens.write (needed to POST /api/v2/apiTokens)
if ! jq -e '.scopes[] | select(.=="apiTokens.write")' < "$tmp_lookup" >/dev/null; then
  echo "[ERROR] DT_TOKEN lacks required scope: apiTokens.write" >&2
  echo "       Present scopes:" >&2
  jq -r '.scopes[]' < "$tmp_lookup" >&2
  rm -f "$tmp_lookup"
  return 1 2>/dev/null || exit 1
fi

rm -f "$tmp_lookup"
echo "[ok] DT_TOKEN is enabled, not expired, and has apiTokens.write"







##
# Create Client id
##
# Extract first two segments before the 2nd dot: "<prefix>.<id>"
IFS='.' read -r _part1 _part2 _rest <<< "$CLIENT_SECRET"
if [[ -z "${_part1:-}" || -z "${_part2:-}" ]]; then
  echo "CLIENT_SECRET is not in the expected format '<a>.<b>.<c...>'"
  exit 1
fi

CLIENT_ID="${_part1}.${_part2}"



##
# EXPORT VARIABLES
##

export DT_INGEST_TOKEN
export DT_OPERATOR_TOKEN
export MONACO_TOKEN
export DT_TENANT_3RDGEN
export DT_TENANT_3GEN
export DT_TENANT
export DT_TOKEN
export CLIENT_ID

##
# print variables
##
echo "MONACO_TOKEN=$MONACO_TOKEN"
echo "DT_TENANT_3RDGEN=$DT_TENANT_3RDGEN"
echo "DT_TENANT_3GEN=$DT_TENANT_3GEN"
echo "DT_TENANT=$DT_TENANT"
echo "DT_TOKEN=$DT_TOKEN"
echo "CLIENT_SECRET=$CLIENT_SECRET"
echo "CLIENT_ID=$CLIENT_ID"


##
# SSO_ENDPOINT determination
##

# DT_TENANT is already set/normalized earlier
: "${DT_TENANT:?DT_TENANT must be set}"

case "$DT_TENANT" in
  *".sprint.dynatracelabs.com"*|*"//*.apps.sprint.dynatrace.com"*)
    SSO_ENDPOINT="https://sso-sprint.dynatracelabs.com/sso/oauth2/token"
    ;;
  *".dev.dynatracelabs.com"*|*"//*.apps.dev.dynatrace.com"*)
    SSO_ENDPOINT="https://sso-dev.dynatracelabs.com/sso/oauth2/token"
    ;;
  *".live.dynatrace.com"*|*".apps.dynatrace.com"*|*".dynatrace.com"*)
    # Production (SaaS): live/apps or any *.dynatrace.com tenant
    SSO_ENDPOINT="https://sso.dynatrace.com/sso/oauth2/token"
    ;;
  *)
    # Fallback: if it’s an internal labs host that isn't clearly dev/sprint, default to prod SSO
    # (Adjust if your org uses other labs realms.)
    SSO_ENDPOINT="https://sso.dynatrace.com/sso/oauth2/token"
    ;;
esac

export SSO_ENDPOINT
echo "SSO_ENDPOINT=$SSO_ENDPOINT"

