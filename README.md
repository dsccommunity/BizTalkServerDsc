# BizTalkServer

**This module is maintained by members of Black Marble staff and not Black Marble itself. Support is offered on a best effort basis by these maintainers.**

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

### 0.1.1.4

* Release with the following fixes:
    * Test for the BizTalk Host Instance did not include the server name

### 0.1.1.3

* Release with the following fixes:
    * Escaping the '\' character in WQL queries

### 0.1.1.2

* Release with the following fixes:
    * Made Credential property standard

### 0.1.1.1

* Release with the following fixes:
    * All resources updated to allow for the reconfiguration of existing instances
    * All resources now accept Credentials

### 0.1.1.0

* Release with the following additional resources:
    * BizTalkServerAdapter
    * BizTalkServerSendHandler
    * BizTalkServerReceiveHandler

### 0.1.0.0

* Initial release with the following resources:
    * BizTalkServerHost
    * BizTalkServerHostInstance
