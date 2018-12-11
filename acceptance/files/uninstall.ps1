$agentVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -like "Puppet Agent*" } |
            Select-Object -Property DisplayName, UninstallString

ForEach ($ver in $agentVer) {
    If ($ver.UninstallString) {
        $uninst = "start /wait "+$ver.UninstallString+" /quiet /norestart /l*vx uninstall_puppet.log"
        Write-Host "Uninstalling: $uninst"
        & cmd.exe /c $uninst
    }

}
