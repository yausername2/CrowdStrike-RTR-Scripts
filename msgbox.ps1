<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to display a message box on the target system.

.DESCRIPTION
The script uses the `msg.exe` utility, which is available in the Professional and Enterprise editions of Windows, to display a hardcoded message box. 
It repeatedly executes the command 50 times to ensure the message is displayed prominently on the target system.

### USE CASE #
Run the script in an RTR session to notify users of a security incident, such as containing a compromised endpoint in the network and alerting the user to contact the security team.
The hardcoded message will inform the user that their system has been contained in the network due to a detected security threat:

 [ SECURITY ALERT ] Your system has been contained in the network due to a detected security threat. Contact the Security team immediately at: security@company.com

The message will be displayed 50 times to ensure visibility.

.NOTES
- `msg.exe` is not available in the Home edition of Windows, so this script will not work on systems running that edition.
- This script is intended for use in incident response scenarios where immediate user notification is required.
- The message is hardcoded and should be modified to suit the specific incident or alert being communicated.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/msgbox.ps1

#>

$Message = "[ SECURITY ALERT ] Your system has been contained in the network due to a detected security threat. Contact the Security team immediately at: security@company.com"

$strCmd = "c:\WINDOWS\system32\msg.exe * " + $Message

for ($i = 0; $i -lt 50; $i++) {
    iex $strCmd
}