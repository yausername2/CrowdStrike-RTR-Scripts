# CrowdStrike RTR Scripts Collection

A collection of useful Real Time Response (RTR) scripts for CrowdStrike Falcon, crafted for SOC analysts and incident responders.

## 🔍 Overview

These scripts help with common tasks during threat hunting, incident response, and triage, such as:

- Collecting artifacts from compromised hosts
- Investigating persistence and privilege escalation
- Rapid triage of suspicious activity

## 📁 Scripts

| Script Name         | Description                                                                 | Platform       |
|---------------------|-----------------------------------------------------------------------------|----------------|
| `get_psTree.ps1`    | Generates a detailed hierarchical process tree, aiding in visualizing parent-child relationships of processes during workflows triggered by endpoint detections. | Windows        |
| `run_autoruns.ps1`  | Executes [Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns), a Sysinternals tool, to identify malicious or unnecessary startup programs and services.  | Windows        |
| `run_thorlite.ps1`  | Executes [Thor Lite](https://www.nextron-systems.com/thor-lite/), a free IOC and YARA rule scanner, to detect malicious artifacts and anomalies on the system.       | Windows        |
| `msgbox.ps1`        | Designed to run in RTR session to notify users of a security incident with a message box on the target system   | Windows        |
| `uninstall_CsRemote.ps1`  | Designed to run in RTR session to uninstalls the CrowdStrike Falcon agent without exposing the maintenance token to the user.   | Windows        |
| `run_browsingHistoryView.ps1`  | Executes [BrowsingHistoryView](https://www.nirsoft.net/utils/browsing_history_view.html) that reads the history data of different Web browsers and save an encrypted copy.   | Windows        |
| `collect_IRData.ps1`  | Collect system information, network details, running processes, services, scheduled tasks, installed software, and other relevant data for incident response purposes.   | Windows        |

## 🧰 Resources

| Name         | Description                                                                 | Version        | Platform       |
|-------------------|-----------------------------------------------------------------------------|----------------|----------------|
| `7za.exe`         | Official standalone console version of 7-Zip with reduced formats support. This version is bundled in the `extra package` of [7-zip](https://github.com/ip7z/7zip/releases/)       | 24.09 (x64)         | Windows        |

## 🧠 Use Cases

These scripts are based on real-world scenarios encountered during SOC operations and malware triage.

## ⚖️ License

This repository is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](LICENSE) file for more details.

### Third-Party Software Notice

This repository includes a binary file: `Resources/7za.exe`

`7za.exe` is part of the 7-Zip project, created by Igor Pavlov, and is **licensed under the "GNU LGPL"**.

- Official site: [https://www.7-zip.org](https://www.7-zip.org)
- License text: See `/Resources/7za-License.txt`

This binary is provided for convenience only. If you prefer, you can replace it with your own copy from the official source.

---


