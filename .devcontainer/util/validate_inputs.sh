#!/bin/bash


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

