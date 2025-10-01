--8<-- "snippets/getting-started.js"
--8<-- "snippets/grail-requirements.md"

## 1. Prerequisites before launching the Codespace

You will need to provide the following variables during the configuration of the codespace:

- DT_TENANT : https://abc123.live.dynatrace.com or sprint -> https://abc123.sprint.dynatracelabs.com no apps in the URL

- MONACO_TOKEN
- CLIENT_ID
- CLIENT_SECRET

Prepare the API token (TENANT_TOKEN) with permissions

- _CaptureRequestData_
- _credentialVault.read_
- _credentialVault.write_
- _DataExport_
- _DataPrivacy_
- _ReadConfig_
- _settings.read_
- _settings.write_
- _WriteConfig_
- _ExternalSyntheticIntegration_
- _events.ingest_
- _slo.read_
- _slo.write_

Prepare OAuthClient (CLIENT_SECRET)

- _app-engine:apps:run_
- _app-engine:apps:install_
- _automation:calendars:read_
- _automation:calendars:write_
- _automation:rules:write_
- _automation:rules:read_
- _automation:workflows:run_
- _automation:workflows:write_
- _automation:workflows:read_
- _settings:schemas:read_
- _settings:objects:write_
- _settings:objects:read_

## 2. Create Dynatrace API Tokens for Kubernetes Observability

This codespace has everything automated for you so you can focus on what matters. You'll need two tokens:

- DT_OPERATOR_TOKEN
- DT_INGEST_TOKEN

We will get this two very easy from the Kubernetes App.

### 2.1. Get the Operator Token and the Ingest Token from the Kubernetes App

1. Open the Kubernetes App (CTRL + K then type Kubernetes for fast access)
2. Select the + Add cluster button
3. Scroll down to the section Install Dynatrace Operator
4. Click on generate Token for the 'Dynatrace Operator' and save it to your Notepad
5. Click on generate Token for the 'Data Ingest Token' and save it to your Notepad
6. You can close the Kubernetes App, we don't need it, we just needed the tokens.

![Kubernetes Tokens](img/k8s_tokens.png)

!!! tip "Let's launch the Codespace"
Now we are ready to launch the Codespace!

<div class="grid cards" markdown>
- [Let's launch Codespaces:octicons-arrow-right-24:](3-codespaces.md)
</div>
