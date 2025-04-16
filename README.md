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
| `run_autoruns.ps1`  | Runs [Autoruns](https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns) to analyze autorun entries and collects system information.  | Windows        |
| `run_thorlite.ps1`  | Executes [Thor Lite](https://www.nextron-systems.com/thor-lite/) scan and collects system information for analysis.       | Windows        |

## 🧠 Use Cases

These scripts are based on real-world scenarios encountered during SOC operations and malware triage.

---


