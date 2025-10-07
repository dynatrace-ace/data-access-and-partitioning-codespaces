#!/bin/bash
# ======================================================================
#          ------- Custom Functions -------                            #
#  Space for adding custom functions so each repo can customize as.    # 
#  needed.                                                             #
# ======================================================================

# transform dynatrace URL to apps URL
# Usage: transformToAppsUrl "https://san35248.sprint.dynatracelabs.com"
# Output: "https://san35248.sprint.apps.dynatracelabs.com"
# Sets environment variable: APPS_URL
transformToAppsUrl() {
  local url="$1"
  
  if [[ -z "$url" ]]; then
    printError "❌ URL parameter is required"
    return 1
  fi
  
  # Check if URL contains dynatracelabs.com
  if [[ "$url" != *"dynatrace"* ]]; then
    printWarn "⚠️  URL does not contain 'dynatracelabs.com', returning original URL"
    echo "$url"
    return 0
  fi
  
  # Transform the URL by adding 'apps.' before 'dynatracelabs.com'
  local transformed_url="${url//dynatrace/apps.dynatrace}"
  
  # Store the result as an environment variable
  export DT_TENANT_3GEN="$transformed_url"
  
  printInfo "✅ APPS_URL environment variable set to: $DT_TENANT_3GEN"

}

# deploy dynatrace configurations (monaco)
deployDynatraceConfig() {

  printInfoSection "Deploying Dynatrace Configurations with Monaco"

  _check_env_var DT_TENANT
  _check_env_var MONACO_TOKEN
  _check_env_var SSO_ENDPOINT
  _check_env_var CLIENT_ID
  _check_env_var CLIENT_SECRET

  # Make sure monaco is executable
  chmod +x $REPO_PATH/assets/dynatrace/config/monaco

  # Copy monaco to local bin directory
  sudo cp $REPO_PATH/assets/dynatrace/config/monaco /usr/local/bin/

  printInfo "Monaco dry run deployment (monaco deploy --dry-run manifest.yaml)"

  # Dry run monaco deployment
  (cd $REPO_PATH/assets/dynatrace/config && monaco deploy --dry-run manifest.yaml)

  # Validate dry run
  dryrun=$(cd "$REPO_PATH/assets/dynatrace/config" && monaco deploy --dry-run manifest.yaml)

  if [[ "$dryrun" == *"Validation finished without errors"* ]]; then
    printInfo "✅ Validation passed."
  else
    printError "❌ Validation failed: 'Validation finished without errors' not found in output."
    return 1  # or exit 1 if you're in a script
  fi

  printInfo "Monaco deployment (monaco deploy manifest.yaml)"

  # Execute monaco deployment
  execute=$(cd "$REPO_PATH/assets/dynatrace/config" && monaco deploy manifest.yaml)

  echo $execute

  if [[ "$execute" == *"Deployment finished without errors"* ]]; then
    printInfo "✅ Deployment execution passed."
  else
    printError "❌ Deployment execution failed: 'Deployment finished without errors' not found in output."
    return 1  # or exit 1 if you're in a script
  fi

  printInfo "Successfully deployed Dynatrace Configurations with Monaco"

}

# delete dynatrace configurations (monaco)
deleteDynatraceConfig() {

  printInfoSection "Deleting Dynatrace Configurations with Monaco"

  _check_env_var DT_TENANT
  _check_env_var MONACO_TOKEN
  _check_env_var SSO_ENDPOINT
  _check_env_var CLIENT_ID
  _check_env_var CLIENT_SECRET

  # Make sure monaco is executable
  chmod +x $REPO_PATH/assets/dynatrace/config/monaco

  # Copy monaco to local bin directory
  sudo cp $REPO_PATH/assets/dynatrace/config/monaco /usr/local/bin/

  printInfo "Generating Monaco deletefile (monaco generate deletefile manifest.yaml)"

  # Generate deletefile from projects
  (cd $REPO_PATH/assets/dynatrace/config && monaco generate deletefile manifest.yaml)

  printInfo "Deleting Configurations in Monaco deletefile"

  # Delete configurations in deletefile
  (cd $REPO_PATH/assets/dynatrace/config && monaco delete -m manifest.yaml)

  # Validate deletion
  deletion=$(cd "$REPO_PATH/assets/dynatrace/config" && monaco delete -m manifest.yaml)

  if [[ "$deletion" == *"Deleting configs..."* ]]; then
    printInfo "✅ Validation passed."
  else
    printError "❌ Validation failed: 'Deleting configs...' not found in output."
    return 1  # or exit 1 if you're in a script
  fi

}

# helper function for checking if environment variable has been set (zsh)
_check_env_var() {
  local var_name="$1"
  eval "var_value=\${$var_name}"
  if [[ -z "$var_value" ]]; then
    printWarn "Environment variable '$var_name' is NOT set."
    return 1
  else
    printInfo "Environment variable '$var_name' is set to '$var_value'."
    return 0
  fi
}

