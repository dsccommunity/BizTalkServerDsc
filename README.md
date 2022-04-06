# BizTalkServerDsc

**This module is maintained by the BizTalk Community**

Module for managing BizTalk Server resources. BizTalk Server must be installed on the machine where the DSC configuration is run.

## Resources

* **BizTalkServerHost** Resource for the management of a BizTalk Server Host.
* **BizTalkServerHostInstance** Resource for the management of a BizTalk Server Host Instance.
* **BizTalkServerAdapter** Resource for the management of a BizTalk Server Adapter.
* **BizTalkServerSendHandler** Resource for the management of a BizTalk Server Send Handler.
* **BizTalkServerReceiveHandler** Resource for the management of a BizTalk Server Receive Handler.

### BizTalkServerHost

* **Name**: The name of the BizTalk Server Host.
* **Trusted**: Trusted BizTalk Server Host.
* **Tracking**: Tracking is enabled for the BizTalk Server Host.
* **Type**: InProcess or Isolated BizTalk Server Host.
* **Is32Bit**: 32-Bit BizTalk Server Host.
* **Default**: Default BizTalk Server Host.
* **WindowsGroup**: Windows Group for the BizTalk Server Host.
* **Ensure**: Present or Absent.
* **Credential**: PSCredentials

### BizTalkServerHostInstance

* **Host**: The name of an existing BizTalk Server Host.
* **Credentials**: Credentials used to run the BizTalk Server Host Instance.
* **Ensure**: Present or Absent.
* **Credential**: PSCredentials

### BizTalkServerAdapter

* **Name**: The name of adapter.
* **MgmtCLSID**: Class Id of the BizTalk Server adapter.
* **Ensure**: Present or Absent.
* **Credential**: PSCredentials

### BizTalkServerSendHandler

* **Adapter**: The name of BizTalk Server adapter.
* **Host**: The name of the BizTalk Server host.
* **Default**: Default send handler for the BizTalk Server adapter.
* **Ensure**: Present or Absent.
* **Credential**: PSCredentials

### BizTalkServerReceiveHandler

* **Adapter**: The name of BizTalk Server adapter.
* **Host**: The name of the BizTalk Server host.
* **Ensure**: Present or Absent.
* **Credential**: PSCredentials

## Versions

### Unreleased

### 0.2.0

