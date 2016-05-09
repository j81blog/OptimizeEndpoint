# OptimizeEndpoint
Optimize Windows 7, 8, 8.1 & 10 for a Non-Persistent environment, e.g. XenDesktop

The following tools are used within the script:
Devcon: https://msdn.microsoft.com/en-us/library/windows/hardware/ff544707%28v=vs.85%29.aspx
rename "%WindowsSdkDir%\tools\x86\devcon.exe" to devcon32.exe
rename "%WindowsSdkDir%\tools\x64\devcon.exe" to devcon64.exe
Nvspbind: http://social.technet.microsoft.com/wiki/contents/articles/191.hyper-v-tools-nvspbind.aspx
PsExec: https://technet.microsoft.com/en-us/sysinternals/psexec.aspx

Please make sure to place the executables in the same folder as the PowerShell or update the script with the correct parameters.
