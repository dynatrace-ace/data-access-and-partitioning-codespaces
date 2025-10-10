## Pre-requisites (estimated time 15min)

### Dynatrace Tenant

!!! note
    If you already have your own tenant, you can jump to [generate tokens](#generate-tokens)

The lab has been tested end-to-end using a **sprint** tenant. While we recommend using a sprint tenant, a production or development tenant should work as well.

1. Search pre-prod-sfm bot in slack

    <p align="left">
    <img src="img/sfm_bot.png" alt="SFM Bot" width="50%">
    </p>

2. type _hey_

    <p align="left">
    <img src="img/hey.png" width="60%">
    </p>

3. type _tenant_, wait a few seconds and select the 1st option

    <p align="left">
    <img src="img/1st-option.png" width="60%">
    </p>

4. Pick sprint, and submit

![](img/pick-sprint.png)

5. Wait for 5min, your tenant details will appear. Once that happens type _hey_ again

![](img/hey-again.png)

6. Type dps, and click on the workflow

![](img/type-dps.png)

7. Enter your tenant details and continue

![](img/tenantdetailsandsubmit.png)

8. DPS should be available soon

![](img/dpssoon.png)

### Generate Tokens

9. Within your Dynatrace tenant, go to `Access Tokens`, and generate a new one with the following permissions. You can give the token any name. Create the token and save it temporarely with you

```bash
ReadConfig, WriteConfig, InstallerDownload
```

10. Go to Account Management, time to create an OAuth Token, with the following scopes:

```bash
storage:buckets:read, storage:bucket-definitions:read, storage:bucket-definitions:write
openpipeline:configurations:read, openpipeline:configurations:write
```

!!! note
    If you've created the tenant following the [previous steps](#dynatrace-tenant), the admin user is not your dynatrace email, but the one provided within the details in the slack conversation with the bot.

    ![](img/hey-again.png)    

    This means that you should be able to access Account Management with the user details provided via slack

![](img/create-oauth.png)

11. Grab client id, secret and account URN, save it temporarely with you

12. Click finish, and with all the collected data, format them as follows:

```bash
DT_TENANT=https://abc12345.sprint.dynatracelabs.com
# Dt tenant stuff
DT_OPERATOR_TOKEN=<dt-access-token>
DT_INGEST_TOKEN=<dt-access-token>
MONACO_TOKEN=<dt-access-token>
## Acc Mgmt stuff
CLIENT_ID=<dt0s02.54N2UVVM>
CLIENT_SECRET=<dt-secret-acc-mgmt>
SSO_ENDPOINT=https://sso-sprint.dynatracelabs.com/sso/oauth2/token
```


### All Set!

Well done! With the tenant, and all the collected variables, you should be ready to start the Data Access & Partitioning lab at any time.

Now just wait until the time of the Hands-on Training

!!! warning
    Do not continue creating the Codespace. Codespaces run for a limited amount of time (cores per hour), so we will run the codespace right before the lab start


Our lab will run in Codespaces. We need to provide the following variables during the configuration. Get each one and keep them in a notepad temporarely

![](img/variables_codespaces.png)