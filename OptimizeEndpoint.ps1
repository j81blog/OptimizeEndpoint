<#
	.DISCLAIMER
	THIS SCRIPT MAKES CONSIDERABLE CHANGES TO THE DEFAULT CONFIGURATION OF WINDOWS.
	This script is provided "AS IS" with no warranties, confers no rights, and is not supported by Citix.
	Please review this script THOROUGHLY before applying to your virtual machine, and disable changes below as necessary 
	to suit your current environment. Usage of this source assumes that you are at the very least familiar with the PowerShell 
	language being used and the tools used to create and debug this file. 
	
	.SYNOPSIS 
	Windows 7/2008R2/8.x/2012R2/10 VDI Golden Image Optimizations Script
	
	.DESCRIPTION 
	Made for Windows 7/2008R2/8.x/2012R2/10
	 
	.NOTES 
	NAME:  OptimizeEndpoint.ps1 
	LASTEDIT: 28/02/2016 
	KEYWORDS: vdi, golden image, windows 7, windows 8, windows 10, optimization, powershell

	Initial version used, version 1.7 from Imgmar Verheij
	http://www.ingmarverheij.com/citrix-pvs-optimize-endpoint-with-powershell/
									
#> 
#FV201605072300
# ===============================================================================
# ==== Global options ===========================================================
$blnDisableTaskOffload = $true      			#True	# Disables TCP/IP task offloading 								- http://support.citrix.com/article/CTX117491
$blnDisableTSODMAXenTools = $true 				#True	# Disable TSO and DMA on XenTools 								- http://support.citrix.com/article/CTX125157
$blnHideHardErrorMessages = $true				#True	# Hide Hard Error Messages
$blnDisableCIFSChangeNotifications = $true		#True	# Disable CIFS Change Notifications
$blnDisableLogonScreensaver = $true				#True	# Disable Logon Screensaver
$blnIncreaseServiceStartupTimeout = $true		#True	# Increase Service Startup Timeout
$blnIncreaseFastSendDatagramThreshold  = $false #False	# Increases the UDP packet size to 1500 bytes  					- http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2040065
$blnSetMaxEndpointCountMult = $false			#False	# Set multiplication factor to the default UDP scavenge value 	- http://support.microsoft.com/kb/2685007/en-us
$blnDisableIPv6 = $false						#False	# Disables IPv6 completely 										- http://social.technet.microsoft.com/wiki/contents/articles/10130.root-causes-for-slow-boots-and-logons-sbsl.aspx
$blnDisableMemoryDumps = $true					#True	# Disable Bug Check Memory Dump
$blnHidePVSstatusicon = $true					#True	# Hide PVS status icon 											- http://forums.citrix.com/thread.jspa?threadID=273278
$blnHideVMwareToolsIcon = $true					#True	# Hide VMware tools icon 										- http://www.blackmanticore.com/c84d61182fa782af965e0abf2d82d6e6
$blnDisableVMwareDebugDriver = $true			#True	# Disable VMware debug driver 									- http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1007652
$blnDisableRSS = $false							#False	# Disable Receive Side Scaling (RSS)							- http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2055853 // http://support.microsoft.com/kb/951037/en-us
$blnIncreaseARPCacheLifespan = $true			#True	# Increases the ARP cache life span 							- http://support.citrix.com/article/ctx127549
$blnRemoveIPv6Binding = $false					#False	# Removes IPv6 binding from network adapters
$blnRemoveHiddenNICs = $true					#True	# Remove hidden NIC's
$blnOptimizeNICs = $true						#True	# Optimize Ethernet adapters
$blnEnableRemoteRegistrySvc = $true				#True	# Enable Remote Registry service
$blnDisableBootLog = $false						#False	# Disable bootlog
$blnDisableBootAnimation = $false				#False	# Disable boot animation 
$blnDisableOfflineFiles = $true					#True	# Disable Offline Files
$blnDisableWindowsAutoupdate = $true			#True	# Disable Windows Autoupdate, not the service
$blnDisableDefragBootOptimize = $true			#True	# Disable Defrag BootOptimizeFunction
$blnDisableBackgroundLayout = $true				#True	# Disable Background Layout Service
$blnDisableLastAccessTimestamp = $true			#True	# Disable Last Access Timestamp
$blnDisableHibernate = $true					#True	# Disable Hibernate	
$blnReduceDedicatedDumpFile2M = $true			#True	# Reduce DedicatedDumpFile DumpFileSize to 2MB (Windows 6.x)
$blnDisableMovetoRecBin = $true					#True	# Disable Move to Recycle Bin
$blnReduceIETempFile = $true					#True	# Reduce IE Temp File
$blnDisableClearPageFileAtShutdown = $true		#True	# Disable Clear Page File at Shutdown
$blnDisableMachinePasswordChanges = $true		#True	# Disable Machine Account Password Changes
$blnDisableWindowsDefender = $false				#False	# Disable Windows Defender (Windows 6.x)						- https://social.technet.microsoft.com/Forums/en-US/de1ae50a-0089-4d91-a3a7-30bf2ceab463/why-cant-i-modify-any-value-under-the-hklmsystemcurrentcontrolsetserviceswindefend-registry?forum=w81previtpro
$blnOptimizeDotNet = $true						#True	# Run ngen.exe executeQueuedItems and Run .Net Tasks			- http://techdows.com/2010/08/what-is-mscorsvw-exe-how-to-disable-it.html
$blnDisableTabletInputSvc = $true				#True	# Disable Touch Keyboard and Handwriting Panel Service service
$blnRemoveOneDrive = $true						#True	# Remove OneDrive on Windows 10
$blnSMB1Tuning = $false							#False	# Tuning SMB 1.0 is required in mixed environments where Windows 2012 / 8 and Windows 2003 or earlier systems connect.
$blnSMB2Tuning = $false							#False	# Tuning SMB 2.0 is required in mixed environments where Windows 2012 / 8 and Windows 2008 / 2008 R2 systems connect.

# ==== Provisioning Services Specific Optimizations =============================
$blnIntermediateBuffering = $false				#False	# Enable intermediate buffering for Local Hard Drive Cache		- http://support.citrix.com/article/CTX126042
$blnWcRamConfiguration = $false					#False	# Improve storage performance of PVS streamed target devices on XenServer / VMWare 	- http://support.citrix.com/article/CTX138199

# ==== XenDesktop Specific Optimizations ========================================
$blnDelayLogoffNotificationEnabled = $false		#False	# When brokering occurs wile still logging off					- http://support.citrix.com/article/CTX138196

# ==== Defrag options ============================================++=============
$blnStartDefrag = $true							#True	# Run the de-fragmentation tool on the selected drives
[string[]]$arrDrivesToDefrag = @()						# Make sure the Defrag/Optimize service is running, defrag will run before the services are being disabled.
$arrDrivesToDefrag += ,@("C:")
#$arrDrivesToDefrag += ,@("D:")
#$arrDrivesToDefrag += ,@("E:")

# ==== Pagefile options =========================================================
$blnSetPagefile = $false						#False	# Change the default pagefile options, set options below. 
# NOTE: Best performance is to let windows decide for it selve. 
#       Also PVS moves the pagefile automagically to the persistent disk.
$strPageFile = 'C:'										# Valid options are "C:", "D:", etc
$intPageFileInitialSize = 2048					#2048	# Valid value is given in MB Eg. 1024, 2048, etc 
$intPageFileMaximumSize = 2048					#2048	# Valid value is given in MB Eg. 1024, 2048, etc 

# ==== Power Plan options =======================================================
$blnPowerSchema = $true							#True	# Set the selected Power schema									- http://blogs.technet.com/b/richardsmith/archive/2007/11/29/powercfg-useful-if-you-know-the-guids.aspx
$intPreferredPlan = 1							#1		# High Performance powerplan improves performance
# 1 = High performance
# 2 = Balanced
# 3 = Power saver

# ==== Event Log Size ===========================================================
$blnReduceEventLogSize	= $true					#True	# Reduce Event Log Size set options below
$intEventLogSize = 64							#64		# Size in kilobytes. E.g 64, 128
$blnRedirectEventLog = $false					#False	# Enable the option to redirect the event logs to other drive/folder
$strRedirectEventLogPath = "D:\EventLogs\"				# Destination path. E.g. 'D:\EventLogs\'

# ==== File options =============================================================
$strPathDevConx86 = (Split-Path $MyInvocation.MyCommand.Path) + "\devcon32.exe"		# Path to 32-bit DevCon
$strPathDevConx64 = (Split-Path $MyInvocation.MyCommand.Path) + "\devcon64.exe"		# Path to 64-bit DevCon
$strPathnvspbindx86 = (Split-Path $MyInvocation.MyCommand.Path) + "\nvspbind32.exe" 	# Path to 32-bit "Hyper-V Network VSP Bind Application"
$strPathnvspbindx64 = (Split-Path $MyInvocation.MyCommand.Path) + "\nvspbind64.exe" 	# Path to 64-bit "Hyper-V Network VSP Bind Application"
$strPathPsExec = (Split-Path $MyInvocation.MyCommand.Path) + "\PsExec.exe" 			# Path to "psexec"
# - To Windows Temp directory:		$env:windir + '\Temp\Transcript.log'
# - To script directory:			(Split-Path $MyInvocation.MyCommand.Path) + '\Transcript_' + (Get-Date -format yyyyMMddHHmmss) + '.log'
$strPathTranscript = (Split-Path $MyInvocation.MyCommand.Path) + '\Transcript_' + (Get-Date -format yyyyMMddHHmmss) + '.log'

# ==== Services =================================================================
$blnServicesToDisable = $true					#True	# Disable certain windows services
$arrServices = @()
# http://www.blackviper.com/service-configurations/black-vipers-windows-7-service-pack-1-service-configurations/
# http://www.blackviper.com/service-configurations/black-vipers-windows-8-1-service-configurations/
# Define each windows version where the SERVICE applies to, split each version wit a pipe sign ("|")
# 5.0 Windows 2000
# 5.1 Windows XP
# 5.2 Windows 2003/2003R2/XP Pro x64
# 6.0 Windows 2008/Vista
# 6.1 Windows 2008R2/7
# 6.2 Windows 2012/8
# 6.3 Windows 2012R2/8.1
# 6.4 Windows 10 (Beta) Best efford
# 10.0 Windows 10
# Example: $arrServices += ,@('Disabled','6.1|6.2|6.3', 'Service')
# Valid service start options are:
# NoChange		- Leave as it currently is (default), no changes made.
# Disabled		- Stop service and change startup to "Disabled"
# 

#Application Layer Gateway Service - Disabled
# Provides support for 3rd party protocol plugins for Internet Connection Sharing. 
# This service is used for mobile devices and is not needed for virtual desktops.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'ALG')
#-
#Application Experience - Disabled
# Not required in managed corporate environments.
$arrServices += ,@('Disabled','6.3|6.4|10.0', 'AeLookupSvc')
# Not required in managed corporate environments.
#-
#BitLocker Drive Encryption Service - Disabled
# Drive encryption is not typically desired in virtual desktop environments.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'BDESVC')
#-
#Background Intelligent Transfer Service - NoChange
# Used by Windows Update / AppSense.
# Virtual desktops which are based off a PVS or MCS golden image do not typically require this service.
# Note: This service is required by many 3rd party applications such as AppSense. 
# if required, consider limiting the bandwidth usage of BITS through GPO.
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'BITS')	
#-
#Computer Browser - Disabled
# Maintains an updated list of computers on the network and supplies this list to computers designated as browsers. 
# if this service is stopped, this list will not be updated or maintained.
# if this service is disabled, any services that explicitly depend on it will fail to start.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'Browser')	
#-
#Bluetooth Support Service - Disabled
# Bluetooth support is not typically needed for virtual desktop environments.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'bthserv')
#-
#Offline Files - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'CscService')
#-
#Disk Defragmenter / Optimize Drives Service - Disabled
# Drive optimization should be performed on the master image during scheduled maintenance.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'defragsvc')
#-
#Device Association Service - Disabled
$arrServices += ,@('Disabled','6.3', 'DeviceAssociationService')
# Enables pairing between the system and wired or wireless devices.
#-
#Device Setup Manager Service - Disabled
# Enables the detection, download and installation of device-related software.
# if this service is disabled, devices may be configured with outdated software, and may not work correctly.
$arrServices += ,@('Disabled','6.3', 'DsmSvc')
#-
#Diagnostic Policy Service - Disabled
# The Diagnostic Policy Services enables problem detection, troubleshooting and resolution for Windows components.
# if this service is stopped, diagnostics will no longer function.
# Unless the diagnostic facilities of Windows is required, this service can be disabled.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'DPS')
#-
#Encrypting File System (EFS) - Disabled
# Provides the core file encryption technology used to store encrypted files on NTFS file system volumes.
# if this service is stopped or disabled, applications will be unable to access encrypted files.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'EFS')
#-
#Windows Media Center Receiver Service - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'ehRecvr')
#-
#Windows Media Center Scheduler Service - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'ehSched')
#-
#Fax Service - Disabled
# Disable if fax services are not needed from virtual desktop.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'Fax')
#-
#Function Discovery Provider Host - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'fdPHost')
#-
#Function Discovery Resource Publication - Disabled
# Publishes this computer and resources attached to this computer so they can be discovered over the network.
# if this service is stopped, network resources will no longer be published and they will not be discovered by other computers on the network.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'FDResPub')
#-
#Home Group Provider - Disabled
# Used to establish Home Groups, not used with virtual machines in a corporate environment
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'HomeGroupProvider')
#-
#Home Group Listner - Disabled
# Used to establish Home Groups, not used with virtual machines in a corporate environment
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'HomeGroupListener')
#-
#Widows Indexing Service - NoChange
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'Indexing-Service-Package')
#-
#IP Helper - Disabled
# Provides tunnel connectivity using IPv6 transition technologies.
# Not required unless IPv6 is used within the datacenter.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'iphlpsvc')
#-
#Media Center Extender Service - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'Mcx2Svc')
#-
#Microsoft iSCSI Initiator Service - Disabled
# Manages Internet SCSI (iSCSI) sessions from this computer to remote iSCSI target devices.
# This should not be needed within a virtual desktop.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'MSiSCSI')
#-
#Network Connectivity Assistant - Disabled
$arrServices += ,@('Disabled','6.2|6.3|6.4|10.0', 'NcaSvc')
#-
#Network List Service - NoChange
# Needed for assignment to domain network location
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'netprofm')
#-
#Network Location Awareness - NoChange
# Needed for assignment to domain network location
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'NlaSvc')
#-
#BranchCache - Disabled
# BrachCache is typically used for network savings to a WAN and is not needed in the virtual desktop environment.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'PeerDistSvc')
#-
#Sensor MonitoringService / Adaptive Brightness - Disabled
# Monitors various sensors in order to expose data and adapt to system and user state.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'SensrSvc')
#-
#Windows Backup - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'SDRSVC')
#-
#Shell Hardware Detection - Disabled
# Provides autoplay functionality not typically needed in a virtual desktop environment.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'ShellHWDetection')
#-
#SNMP Trap Service - Disabled
# Receives trap messages generated by local or remote Simple Network Management Protocol (SNMP) agents 
# and forwards the messages to SNMP management programs running on this computer.
# if this service is stopped, SNMP-based programs on this computer will not receive SNMP trap messages.
# May be required for certain monitoring tools.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'SNMPTRAP')
#-
#SSDP Discovery - Disabled
# Discovers network devices and services that use the SSDP protocol. SSDP discovery is not typically used in corporate environments.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'SSDPSRV')
#-
#Secure Socket Tunneling Protocol Service - Disabled
# Provides support for the Secure Socket Tunneling Protocol (SSTP) to connect to remote computers using VPN.
# if this service is disabled, users will not be able to use SSTP to access remote servers.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'SstpSvc')
#-
#Superfetch (Non-persistent desktops only) - Disabled
# All cached files which are used to determine SuperFetch behavior are deleted on pooled desktops.
# Windows 8 should disabled this service automatically for non-persistent desktops.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'SysMain')
#-
#Microsoft Software Shadow Copy Provider Service - Disabled
# Consider Disabling (Disable after PVS imaging)
# Manages software-based volume shadow copies taken by the volume shadow copy service.
# if this service is stopped, softwarebased volume shadow copies cannot be managed.
# Do not disable this service if using personal vdisk. This service is often required by other 3rd party applications.
$arrServices += ,@('Disabled','6.3|6.4|10.0', 'swprv')
#-
#Tablet PC Input Service / Touch Keyboard and Handwriting Panel Service - NoChange
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'TabletInputService')
#-
#Telephony Service - Disabled
# Provides Telephony API (TAPI) support for programs that control telephony devices on the local computer and,
# through the LAN, on servers that are also running the service.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'TapiSrv')
#-
#Themes Service - Win7 NoChange, Win8 and up Disabled
# Note: Unlike in Windows 7, Desktop Composition in Windows 8 does not require the themes service
# Provides user experience theme management.
# In Windows 8 the Desktop Window Manager still runs if the themes service is disabled.
# Disabling the themes service can alter the appearance of the desktop. (Disables taskbar transparency)
$arrServices += ,@('NoChange','6.1', 'Themes')
$arrServices += ,@('Disabled','6.2|6.3|6.4|10.0', 'Themes')
#-
#Distributed Link Tracking Client - Disabled
# Maintains links between NTFS files within a computer or across computers in a network.
# This service may be required for certain editions of AVG Anti-Virus.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'TrkWks')
#-
#Interactive Services Detection - Disabled
$arrServices += ,@('Disabled','6.2|6.3|6.4|10.0', 'UI0Detect')
#-
#UPnP Device Host - Disabled
# Allows UPnP devices to be hosted on the computer. Is dependent on the SSDP Discovery service above.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'upnphost')
#-
#Desktop Window Manager Session Manager - NoChange
# Disable only if Aero not necessary
$arrServices += ,@('NoChange','6.1', 'UxSms')
#-
#Volume Shadow Copy - Disabled
# Consider Disabling (Disable after PVS Imaging) Do not disable this service if using personal vdisk!
# Manages and implements volume shadow copies used for backup and other purposes.
# if this service is stopped, shadow copies will be unavailable for backup and the backup may fail.
# Do not disable this service if using personal vdisk. This service is often required by other 3rd party applications.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'VSS')
#-
#Block Level Backup Engine Service - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'wbengine')
# Windows backup is not typically needed for virtual desktop deployments.
#-
#Windows Connect Now – Config Regstrar Service - Disabled
# Not required in virtual desktop environments as virtual machines typically do not use wireless internet.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'wcncsvc')
#-
#Windows Color System Service - Disabled
# The WcsPlugInService service hosts thirdparty Windows color system color device model and gamut map model plug-in modules.
# These plug-in modules are vendor-specific extensions to the Windows color system baseline color device and gamut map models.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WcsPlugInService')
#-
#Diagnostic Service Host - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WdiServiceHost')
#-
#Diagnostic System Host - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WdiSystemHost')
#-
#Problem Reports and Solutions Control Panel Support - Disabled
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'wercplsupport')
#-
#Windows Error Reporting Service - Disabled
# Allows errors to be reported when programs stop working or responding.
# Also allows logs to be generated for diagnostic and repair services.
# if this service is stopped, error reporting might not work correctly and
# results of diagnostic services and repairs might not be displayed.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WerSvc')
#-
#Windows Defender - NoChange
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'WinDefend')
#-
#WLAN AutoConfig - Disabled
# Not required in virtual desktop environments as virtual machines typically do not use wireless internet.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'Wlansvc')
#-
#Windows Media Player Network Sharing Service - Disabled
# Shares Windows Media Player libraries to other systems. This is typically not required in corporate environments.
$arrServices += ,@('Disabled','6.1|6.2|6.3', 'WMPNetworkSvc')
#-
#Family Safety Service (Parental Controls) - Disabled
# Service provides backwards compatibility to Vista parental control and can be disabled in a virtual corporate environment.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WPCSvc')
#-
#Windows Search - NoChange
# Consider Disabling, High User Impact (Solution for Outlook repair action)
# Remove all files and folders (default is Start Menu and local User Profiles) from index options.
# Doing so enables user to search for file contents on Windows file servers running the Windows Search service.
# if this functionality is not required, the Windows Search service can be disabled.
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'WSearch')
#-
#Security Center - Disabled
# Used to monitor and report security health settings on a system.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'wscsvc')
#-
#Windows Update - NoChange
# Not required for PVS or MCS based environments,
# or if Windows Update has been replaced with an alternative deployment solution.
# Note that Windows Update can also be configured by group policy.
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'wuauserv')
#-
#WWAN Service - Disabled
# Not required in virtual desktop environments as virtual machines typically do not use wireless internet.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'WwanSvc')
#-

# ---- 3rd Party Services ----
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'AdobeARMservice')				#Disabled	# Adobe Acrobat Updater keeps your Adobe software up to date.
$arrServices += ,@('Disabled','6.1|6.2|6.3|6.4|10.0', 'AdobeFlashPlayerUpdateSvc')		#Disabled	# This service keeps your Adobe Flash Player installation up to date with the latest enhancements 
$arrServices += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'CCMExec')						#NoChange	# System Center SMS Agent Host Service 

# ==== Scheduled Tasks ==========================================================
$blnTasksToDisable = $true
$arrTasks = @()

# Valid task options are:
# NoChange			- Leave as it currently is, no changes made.
# Disable			- Disable the task specified.
# DisableAsSystem	- Same as 'Disable' but done with SYSTEM privileges

$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\Application Experience\AitAgent')											#Disable	# Aggregates and uploads Application Telemetry information if opted-in to the Microsoft Customer Experience Improvement Program.
$arrTasks += ,@('Disable','6.1|6.2|6.3|10.0', 'microsoft\windows\Application Experience\ProgramDataUpdater')							#Disable	# Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program
$arrTasks += ,@('Disable','6.2|6.3|6.4|10.0', 'microsoft\windows\Application Experience\StartupAppTask')								#Disable	# Scans startup entries and raises notification to the user if there are too many startup entries.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Application Experience\Microsoft Compatibility Appraiser')			#Disable	# Note: Downloads Windows 10 binaries.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Autochk\Proxy')													#Disable	# This task collects and uploads autochk SQM data if optedin to the Microsoft Customer Experience Improvement Program.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\Bluetooth\UninstallDeviceTask')												#Disable	# This tasks uninstalls the PnP device associated with a specified Bluetooth service ID.
$arrTasks += ,@('Disable','6.3|6.4|10.0', 'microsoft\windows\CHKDSK\ProactiveScan')														#Disable	# NTFS Volume Health Scan
$arrTasks += ,@('Disable','6.2|6.3|6.4|10.0', 'microsoft\windows\Customer Experience Improvement Program\BthSQM')						#Disable	# The Bluetooth CEIP (Customer Experience Improvement Program) task collects Bluetooth related statistics and information about your machine and sends it to Microsoft. The information received is used to help improve the reliability, stability, and overall functionality of Bluetooth in Windows.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Customer Experience Improvement Program\Consolidator')				#Disable	# if the user has consented to participate in the Windows Customer Experience Improvement Program, this job collects and sends usage data to Microsoft.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Customer Experience Improvement Program\KernelCeipTask')			#Disable	# The Kernel CEIP (Customer Experience Improvement Program) task collects additional information about the system and sends this data to Microsoft. if the user has not consented to participate in Windows CEIP, this task does nothing.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Customer Experience Improvement Program\UsbCeip')					#Disable	# The USB CEIP (Customer Experience Improvement Program) task collects Universal Serial Bus related statistics and information about your machine and sends it to the Windows Device Connectivity engineering group at Microsoft. The information received is used to help improve the reliability, stability, and overall functionality of USB in Windows. if the user has not consented to participate in Windows CEIP, this task does not do anything.
$arrTasks += ,@('Disable','6.2|6.3|6.4|10.0', 'microsoft\windows\Customer Experience Improvement Program\Uploader')						#Disable	# This job sends data about windows based on user participation in the Windows Customer Experience Improvement Program
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Defrag\ScheduledDefrag')											#Disable	# This task optimizes local storage drives.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Diagnosis\Scheduled')												#Disable	# The Windows Scheduled Maintenance Task performs periodic maintenance of the computer system by fixing problems automatically or reporting them through the Action Center.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector')		#Disable	# The Windows Disk Diagnostic reports general disk and system information to Microsoft for users participating in the Customer Experience Program.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver')			#Disable	# This task warns users about faults that occur on disks that support Self-Monitoring and Reporting Technology.
$arrTasks += ,@('Disable','6.3|6.4|10.0', 'microsoft\Windows\FileHistory\File History (maintenance mode)')								#Disable	# Protects user files from accidental loss by copying them to a backup location when the system is unattended
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\Windows\Location\Notifications')													#Disable	# Location Activity
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Maintenance\WinSAT')												#Disable	# Measures a system's performance and capabilities
$arrTasks += ,@('Disable','6.3', 'microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser')										#Disable	# Mobile Broadband Account Experience Metadata Parser
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\Windows\PerfTrack\BackgroundConfigSurveyor')										#Disable	# Performance Tracing Idle Task: Background configuration surveyor
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\MobilePC\HotStart')															#Disable	# Launches applications configured for Windows HotStart
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\MUI\lpremove')														#Disable	# Disable removal of Language packs
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Power Efficiency Diagnostics\AnalyzeSystem')						#Disable	# This task analyzes the system looking for conditions that may cause high energy use.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\RAC\RacTask')														#Disable	# Microsoft Reliability Analysis task to process system reliability data.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\Ras\MobilityManager')														#Disable	# Provides support for the switching of mobility enabled VPN connections if their underlying interface goes down.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Registry\RegIdleBackup')											#Disable	# Registry Idle Backup Task
$arrTasks += ,@('Disable','6.2|6.3|6.4|10.0', 'microsoft\windows\Shell\FamilySafetyMonitor')											#Disable	# Initializes Family Safety monitoring and enforcement.
$arrTasks += ,@('Disable','6.2|6.3|6.4|10.0', 'microsoft\windows\Shell\FamilySafetyRefresh')											#Disable	# Synchronizes the latest settings with the Family Safety website.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\SideShow\AutoWake')															#Disable	# This task automatically wakes the computer and then puts it to sleep when automatic wake is turned on for a Windows SideShow-compatible device.
$arrTasks += ,@('Disable','6.4|10.0', 'microsoft\windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents')								#Disable	# Schedules a memory diagnostic in response to system events.
$arrTasks += ,@('Disable','6.4|10.0', 'microsoft\windows\MemoryDiagnostic\RunFullMemoryDiagnostic')										#Disable	# Detects and mitigates problems in physical memory (RAM).
$arrTasks += ,@('Disable','6.4|10.0', 'microsoft\windows\RecoveryEnvironment\VerifyWinRE')												#Disable	# Validates the Windows Recovery Environment.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\SideShow\GadgetManager')													#Disable	# This task manages and synchronizes metadata for the installed gadgets on a Windows SideShow-compatible device.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\SideShow\SessionAgent')														#Disable	# This task manages the session behavior when multiple user accounts exist on a Windows SideShow-compatible device.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\SideShow\SystemDataProviders')												#Disable	# This task provides system data for the clock, power source, wireless network strength, and volume on a Windows SideShow-compatible device.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\SystemRestore\SR')													#Disable	# This task creates regular system protection points.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\UPnP\UPnPHostConfig')														#Disable	# Sets the UPnP service to autostart.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\WDI\ResolutionHost')												#Disable	# The Windows Diagnostic Infrastructure Resolution host enables interactive resolutions for system problems detected by the Diagnostic Policy Service. It is triggered when necessary by the Diagnostic Policy Service in the appropriate user session. if the Diagnostic Policy Service is not running, the task will not run
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Windows Media Sharing\UpdateLibrary')								#Disable	# This task updates the cached list of folders and the security permissions on any new files in a user’s shared media library.
$arrTasks += ,@('Disable','6.1|6.2|6.3', 'microsoft\windows\WindowsBackup\ConfigNotification')											#Disable	# This scheduled task notifies the user that Windows Backup has not been configured.
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'microsoft\windows\Windows Filtering Platform\BfeOnServiceStartTypeChange')			#Disable	# This task adjusts the start type for firewall-triggered services when the start type of the Base Filtering Engine (BFE) is disabled.
$arrTasks += ,@('Disable','6.2|6.3', 'microsoft\windows\TaskScheduler\Idle Maintenance')												#Disable	# Maintenance Scheduler Launcher Task
$arrTasks += ,@('Disable','6.2|6.3', 'microsoft\windows\TaskScheduler\Manual Maintenance')												#Disable	#
$arrTasks += ,@('Disable','6.2|6.3', 'microsoft\windows\TaskScheduler\Regular Maintenance')												#Disable	#
$arrTasks += ,@('DisableAsSystem','6.2|6.3', 'microsoft\windows\TaskScheduler\Maintenance Configurator')								#Disable	# To disable: DisableAsSystem
$arrTasks += ,@('Disable','6.3|10.0', 'microsoft\Windows\TPM\Tpm-Maintenance')															#Disable	# This task supports the Trusted Platform Module (TPM) by performing background actions on behalf of the OS.
$arrTasks += ,@('NoChange','6.3|10.0', 'microsoft\Windows Defender\Windows Defender Cache Maintenance')									#NoChange	# Can be disabled in case an alternative virus and malware protection has been implemented.
$arrTasks += ,@('NoChange','6.3|10.0', 'microsoft\Windows Defender\Windows Defender Cleanup')											#NoChange	# Can be disabled in case an alternative virus and malware protection has been implemented.
$arrTasks += ,@('NoChange','6.3|10.0', 'microsoft\Windows Defender\Windows Defender Scheduled Scan')									#NoChange	# Can be disabled in case an alternative virus and malware protection has been implemented.
$arrTasks += ,@('NoChange','6.3|10.0', 'microsoft\Windows Defender\Windows Defender Verification')										#NoChange	# Can be disabled in case an alternative virus and malware protection has been implemented.
$arrTasks += ,@('NoChange','6.1', 'microsoft\Windows Defender\MP Scheduled Scan')														#NoChange	# Can be disabled in case an alternative virus and malware protection has been implemented.

# 3rd Party Tasks
$arrTasks += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'microsoft\Configuration Manager\Configuration Manager Health Evaluation')			#NoChange	#
$arrTasks += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'microsoft\Configuration Manager\Configuration Manager Idle Detection')				#NoChange	#
$arrTasks += ,@('Disable','6.1|6.2|6.3|6.4|10.0', 'Adobe Acrobat Update Task')															#Disable	#

# ==== Features =================================================================
$blnFeaturesToDisable = $true																		#True	# Remove certain windows features
$arrFeatures = @()
$arrFeatures += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'MediaPlayback')								#NoChange	# Required for Windows Media Player
$arrFeatures += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'WindowsMediaPlayer')							#NoChange	# Required for Windows Media Player
$arrFeatures += ,@('Remove','6.1', 'MediaCenter')													#Remove		# Media Center
$arrFeatures += ,@('Remove','6.1', 'OpticalMediaDisc')												#Remove		# Windows DVD Maker
$arrFeatures += ,@('NoChange','6.1', 'TabletPCOC')													#NoChange	# Tablet Components
$arrFeatures += ,@('Remove','6.1|6.2|6.3|6.4|10.0', 'Printing-Foundation-InternetPrinting-Client')	#Remove
$arrFeatures += ,@('Remove','6.1|6.2|6.3|6.4|10.0', 'Printing-Foundation-Features')					#Remove		
$arrFeatures += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'FaxServicesClientPackage')					#Remove		# Windows Fax and Scan
$arrFeatures += ,@('NoChange','6.1', 'Printing-XPSServices-Features')								#NoChange	# XPS Printer
$arrFeatures += ,@('NoChange','6.1', 'Xps-Foundation-Xps-Viewer')									#NoChange	# XPS Viewer
$arrFeatures += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'SearchEngine-Client-Package')				#NoChange	# Windows Search
$arrFeatures += ,@('NoChange','6.1|6.2|6.3|6.4|10.0', 'Indexing-Service-Package')					#NoChange	# Indexing Service

# ==== Appx Apps to uninstall =================================================
$blnAppxAppsToRemove = $true													#True
$arrAppxApps = @()
$arrAppxApps += ,@('Remove','6.4|10.0','*3DBuilder*')							# Uninstall 3D Builder
$arrAppxApps += ,@('Remove','6.4|10.0','*Appconnector*')						# Uninstall 
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*bingfinance*')					# Uninstall Money
$arrAppxApps += ,@('Remove','6.2|6.3','*BingFoodAndDrink*')						#
$arrAppxApps += ,@('Remove','6.2|6.3','*BingHealthAndFitness*')					#
$arrAppxApps += ,@('Remove','6.2|6.3','*BingMaps*')								#
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*bingnews*')					# Uninstall News
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*bingsports*')					# Uninstall Sports
$arrAppxApps += ,@('Remove','6.2|6.3','*BingTravel*')							#
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*bingweather*')					# Uninstall Weather
$arrAppxApps += ,@('Remove','6.2|6.3','*Camera*')								#
$arrAppxApps += ,@('Remove','6.2|6.3','*OneDrive*')								#
$arrAppxApps += ,@('Remove','6.4|10.0','*getstarted*')							# Uninstall Get Started
$arrAppxApps += ,@('Remove','6.2|6.3','*HelpAndTips*')							#
$arrAppxApps += ,@('Remove','6.4|10.0','*officehub*')							# Uninstall Get Office
$arrAppxApps += ,@('Remove','6.4|10.0','*solitairecollection*')					# Uninstall Microsoft Solitaire Collection
$arrAppxApps += ,@('Remove','6.2|6.3','*Media.PlayReadyClient.2*')				# 2x
$arrAppxApps += ,@('Remove','6.2|6.3','*Media.PlayReadyClient.2*')				#
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*onenote*')						# Uninstall OneNote
$arrAppxApps += ,@('Remove','6.4|10.0','*people*')								# Uninstall People
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*skypeapp*')					# Uninstall Get Skype
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*photos*')						# Uninstall Photos
$arrAppxApps += ,@('Remove','6.2|6.3','*Reader*')								#
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*windowsalarms*')				# Uninstall Alarms and Clock
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*windowscalculator*')			# Uninstall Calculator
$arrAppxApps += ,@('Remove','6.4|10.0','*windowscamera*')						# Uninstall Camera
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*windowscommunicationsapps*')	# Uninstall Calendar and Mail
$arrAppxApps += ,@('Remove','6.4|10.0','*windowsmaps*')							# Uninstall Maps
$arrAppxApps += ,@('Remove','6.4|10.0','*windowsphone*')						# Uninstall Phone Companion
$arrAppxApps += ,@('Remove','6.2|6.3','*WindowsReadingList*')					#
$arrAppxApps += ,@('Remove','6.4|10.0','*soundrecorder*')						# Uninstall Voice Recorder
$arrAppxApps += ,@('Remove','6.2|6.3','*WindowsScan*')							#
$arrAppxApps += ,@('Remove','6.4|10.0','*windowsstore*')						# Uninstall Store
$arrAppxApps += ,@('Remove','6.4|10.0','*xboxapp*')								# Uninstall Xbox
$arrAppxApps += ,@('Remove','6.2|6.3','*XboxLIVEGames*')						#
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*zunemusic*')					# Uninstall Groove Music
$arrAppxApps += ,@('Remove','6.2|6.3|6.4|10.0','*zunevideo*')					# Uninstall Movies & TV


# ===============================================================================
# ==== Only change values below this line if you understand the implications ====
# ===============================================================================

# ------------ PowerShell Version Check and start with logging ------------------
$blnTroubleShooting = $False							#False	# Start troubleshooting (when having issues with this script)
if ($blnTroubleShooting) {
	$PSDefaultParameterValues = @{"*:Verbose"=$true}
	$VerbosePreference = 'Continue'
}

$Host.UI.RawUI.WindowTitle = "VDI Optimize"
$newsize = $Host.UI.RawUI.buffersize
$newsize.height = 2000
$newsize.width = 120
$Host.UI.RawUI.buffersize = $newsize
$newsize = $Host.UI.RawUI.WindowSize
$newsize.height = 40
$newsize.width = 120
$Host.UI.RawUI.WindowSize = $newsize
#clear-host

$PowerShellVersion = (Get-Host | Select-Object Version).Version.Major
if ($PowerShellVersion -ge 4 ) {
	if ($psISE -ne $null) {
		cls
		Write-Host ""
		Write-Host ""
		Write-Host ""
		Write-Host ""
		Write-Host ""
		Write-Host ""
		Write-Host -ForegroundColor Yellow "==========================================================="
		Write-Host ""
		Write-Warning "PowerShell ISE detected!"
		Write-Warning "- This script may not run correctly."
		Write-Warning "- No transcript will be created!"
		Write-Host ""
		Write-Host -ForegroundColor Yellow "==========================================================="
		$time = 15 #Seconds
		$length = $time / 100
		while($time -gt 0) {
			$min = [int](([string]($time/60)).split('.')[0])
			$text = " " + $min + " minutes " + ($time % 60) + " seconds left"
			Write-Progress "Pausing Script" -status $text -perc ($time/$length)
			start-sleep -s 1
			$time--
		}		
	}
	Else { Start-Transcript -Path $strPathTranscript -Append | out-null }
} Else {
	cls
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host -ForegroundColor Yellow "==============================================================================="
	Write-Host ""
	Write-Warning "Script only functions when PowerShell version 4 or higher is installed"
	Write-Warning "Please Upgrade to version 4 or higher"
	Write-Host ""
	Write-Warning "Please install:"
	Write-Warning " - .Net Framework 4.5"
	Write-Warning " - Powershell 4 (KB2819745)"
	Write-Host ""
	Write-Host -ForegroundColor Yellow "==============================================================================="
	Write-Host ""
	Write-Host ""
	Exit 1
}

# -------------------------------------------------------------------------------

# ------------------------------ Functions --------------------------------------

function Use-RunAs {    
    # Check if script is running as Adminstrator and if not use RunAs 
    # Use Check Switch to check if admin 
    # http://gallery.technet.microsoft.com/scriptcenter/63fd1c0d-da57-4fb4-9645-ea52fc4f1dfb
    [cmdletbinding()]
    param (
		[Switch]$Check
	) 
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
    if ($Check) { return $IsAdmin }     
    if ($MyInvocation.ScriptName -ne "") {  
        if (-not $IsAdmin) {  
            try {  
                $arg = "-file `"$($MyInvocation.ScriptName)`"" 
                Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop'  
            } catch { 
                Write-Warning "Failed to restart script with runas"  
                break               
            } 
            exit # Quit this session of powershell 
        }  
    } else {  
        Write-Warning "Script must be saved as a .ps1 file first"  
        break  
    }  
}

function Unblock-Files {
	# http://andyarismendi.blogspot.nl/2012/02/unblocking-files-with-powershell.html
	[cmdletbinding(DefaultParameterSetName="ByName", SupportsShouldProcess=$true)]
	param (
		[parameter(Mandatory=$true, ParameterSetName="ByName", Position=0)] [string] $FilePath,
		[parameter(Mandatory=$true, ParameterSetName="ByInput", ValueFromPipeline=$true)] $InputObject
  	)
	begin {       
		Add-Type -Namespace Win32 -Name PInvoke -MemberDefinition @"
		// http://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
		[DllImport("kernel32", CharSet = CharSet.Unicode, SetLastError = true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		private static extern bool DeleteFile(string name);
		public static int Win32DeleteFile(string filePath) {
			bool is_gone = DeleteFile(filePath); return Marshal.GetLastWin32Error();}
		[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
		static extern int GetFileAttributes(string lpFileName);
		public static bool Win32FileExists(string filePath) {return GetFileAttributes(filePath) != -1;}
"@
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			'ByName' {
				$input_paths = Resolve-Path -Path $FilePath | ? {[IO.File]::Exists($_.Path)} | Select -Exp Path
			}
			'ByInput' {
				if ($InputObject -is [System.IO.FileInfo]) {
					$input_paths = $InputObject.FullName
					}
			}
		}
		$input_paths | % { 
			#Determine PowerShell engine version
			if ($PSVersionTable.psversion.Major -ge 3) {
				#PowerShell 3 has a native cmdlet
				Unblock-File -Path $_
			} else { 
				#PowerShell 1/2: Use pinvoke to access kernel32.dll API's 
				if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
					if ($PSCmdlet.ShouldProcess($_)) {
						$result_code = [Win32.PInvoke]::Win32DeleteFile($_ + ':Zone.Identifier')
						if ([Win32.PInvoke]::Win32FileExists($_ + ':Zone.Identifier')) {
							Write-Error ("Failed to unblock '{0}' the Win32 return code is '{1}'." -f $_, $result_code)
						}
					}
				}
			}
		}
	}
}
#-

# Defrag function for Windows 7 based OS's
Function Start-DiskDefrag { 
    [CmdletBinding()] 
    [OutputType([Object])] 
    Param ( 
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)] [string] $ComputerName="localhost", 
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)] [string] $DriveLetter="C:", 
        [Parameter()] [switch] $Force=$false
    )
	Write-Host -NoNewLine -ForegroundColor Gray (" - Starting defrag on drive (" + $ComputerName + "): " + $DriveLetter)
	Try { 
		$Volume = Get-WmiObject -ComputerName $ComputerName -Class win32_volume -Filter "DriveLetter='$DriveLetter'" 
	} 
	Catch { } 
	Write-Verbose ""
	Write-Verbose "Volume retrieved successfully.."             
	if ($force) { 
		Write-Verbose "force parameter detected, disk defragmentation will be performed regardless of the free space on the volume" 
		Write-Verbose "Defragmenting volume $driveletter on $computername" 
		$Defrag = $Volume.Defrag($true)                 
	} Else { 
		Write-Verbose "Checking free space for volume $driveletter on $computername" 
		if (($Volume.FreeSpace /1GB) -lt ($Volume.Capacity / 1GB) * 0.15) { 
			Write-Error "Volume $Driveletter on $computername does not have sufficient free space to allow a disk defragmentation, to perform a disk ` 
			defragmentation either free up some space on the volume or use Start-DiskDefrag with the -force switch" 
		} Else {               
			Write-Verbose "Volume has sufficient free space for a defragmentation to be performed" 
			Write-Verbose "Beginning disk defragmentation" 
			$Defrag = $Volume.Defrag($false) 
		} 
	}
	Switch ($Defrag.ReturnValue) { 
		0 { Write-Host -ForegroundColor Green " (done)`r" } 
		1 { Write-Host -ForegroundColor Red " (error) Access Denied`r" } 
		2 { Write-Host -ForegroundColor Red " (error) Defragmentation is not supported for this volume`r" } 
		3 { Write-Host -ForegroundColor Red " (error) Volume dirty bit is set`r" } 
		4 { Write-Host -ForegroundColor Red " (error) Insufficient disk space`r" } 
		5 { Write-Host -ForegroundColor Red " (error) Corrupt master file table detected`r" } 
		6 { Write-Host -ForegroundColor Red " (error) The operation was cancelled`r" } 
		7 { Write-Host -ForegroundColor Red " (error) The operation was cancelled`r" } 
		8 { Write-Host -ForegroundColor Red " (error) A disk defragmentation is already in process`r" } 
		9 { Write-Host -ForegroundColor Red " (error) Unable to connect to the defragmentation engine`r" } 
		10 { Write-Host -ForegroundColor Red " (error) A defragmentation engine error occurred`r" } 
		11 { Write-Host -ForegroundColor Red " (error) Unknown error`r" } 
	}                               
}
#-

function Run-Program {
	#
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true)][string]$Command,
		[Parameter(Mandatory=$false)][string]$ArgumentList="",
		[Parameter(Mandatory=$false)][switch]$Show=$false
	)
	$ProgInfo  = New-Object System.Diagnostics.ProcessStartInfo
	$ProgInfo.FileName = $Command
	$ProgInfo.RedirectStandardError = $true
	$ProgInfo.RedirectStandardOutput = $true
	$ProgInfo.UseShellExecute = $UseShellExecute
	$ProgInfo.Arguments = $ArgumentList
	$Prog = New-Object System.Diagnostics.Process
	$Prog.StartInfo = $ProgInfo
	$Prog.Start() | Out-Null
	$Prog.WaitForExit()
	$value = "" | Select-Object -Property StdOut,StdErr,ExitCode
	$Value.Stdout = $Prog.StandardOutput.ReadToEnd()
	$Value.Stderr = $Prog.StandardError.ReadToEnd()
	$Value.ExitCode	= $Prog.ExitCode
	if ($Show -eq $false) { 
		if (($Prog.ExitCode -eq 0) -Or ($Prog.ExitCode -eq 3010)) {
			Write-Host -ForegroundColor Green " (done)`r"
		} Elseif ($Prog.ExitCode -ge 1) {
			Write-Host -ForegroundColor Red (" (error) [" + $Prog.ExitCode + "]`r")
			Write-Verbose ('Output: ' + $Value.Stdout)
			Write-Verbose ('Error:  ' + $Value.Stderr)
		}
	}
	return $Value
}
#-

function Set-PageFile {
	# https://gallery.technet.microsoft.com/scriptcenter/Script-to-configure-e8d85fee
	[cmdletbinding()]
    PARAM(
        [string]$Drive,
        [int]$InitialSize,
        [int]$MaximumSize
    )
	$value = "" | Select-Object -Property modified,exitcode
	$value.modified = $false
	$value.exitcode = 0
	$ComputerSystem = $null
	$CurrentPageFile = $null
	If($IsAutomaticManagedPagefile) {
		#We must enable all the privileges of the current user before the command makes the WMI call.
		Write-Verbose ('Setting AutomaticManagedPageFile to False')
		$SystemInfo=Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
		$SystemInfo.AutomaticManagedPageFile = $false
		[Void]$SystemInfo.Put()
	}
	$PageFile = Get-WmiObject -Class Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $Drive'"
	Try {
		If($PageFile -ne $null) {
			Write-Verbose 'Deleting pagefile'
			$PageFile.Delete()
		}
		Write-Verbose 'Resetting pagefile settings'
		Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name="$Drive\pagefile.sys"; InitialSize = 0; MaximumSize = 0} -EnableAllPrivileges |Out-Null
		$PageFile = Get-WmiObject Win32_PageFileSetting -Filter "SettingID='pagefile.sys @ $Drive'"
		Write-Verbose 'Changing the "InitialSize"'
		$PageFile.InitialSize = $InitialSize
		Write-Verbose 'Changing the "MaximumSize"'
		$PageFile.MaximumSize = $MaximumSize
		[Void]$PageFile.Put()
		Write-Verbose 'Finished'
		$value.modified = $true
	} Catch {
		$ErrorMessage = $_.Exception.Message
		$FailedItem = $_.Exception.ItemName
		Write-Verbose ('Caught an error, No permission?')
		Write-Verbose ('ErrorMessage: ' + $ErrorMessage)
		Write-Verbose ('FailedItem: ' + $FailedItem)
		$value.exitcode = 1
	}		
	Return $value
}

#-

# Tests if specified value exist in path
# http://blogs.msdn.com/b/candede/archive/2010/01/13/test-registry-paths.aspx
function Test-RegPathValue {
	[cmdletbinding()]
	Param (
		[Parameter(mandatory=$true,position=0)][string]$Path,
		[Parameter(mandatory=$true,position=1)][string]$Value
	)
	$compare = ((Get-ItemProperty -ErrorAction SilentlyContinue -LiteralPath $Path).psbase.members) | %{$_.name} | compare $Value -IncludeEqual -ExcludeDifferent -ErrorAction SilentlyContinue
	If($compare.SideIndicator -like "==") {
		Return $true 
	} Else { 
		Return $false
	}
}
#-

# Check if a Windows service exists
Function ServiceExists {
	[cmdletbinding()]
	PARAM(
		[string] $ServiceName
	) 
    [bool] $Return = $false
    if ( Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'" ) {
        $Return = $true
    }
    Return $Return
}
#-

# Check if path exist if not try to create
function CreateRegistryPath {
	[cmdletbinding()]
	PARAM(
		[string] $keyPath
	)
	$root = ($keyPath.split(":"))[0] + ':'
	$key = ""
	foreach ($item in (($keyPath.split(":"))[1].split("\"))) {
		$key = $key + $item 
		if ( -not (Test-Path $root$key)) {
			try {
				New-Item -Path "$($root)$($key)"
			}
			catch {
				Return $false
				Exit
			}
		}
		$key = $key + "\"
	}
	if (Test-Path $keyPath) {
		Return $true 
	} Else { Return $false }
}
#-

# Tests if specified value exist in path
function Test-RegPathValue {
	[cmdletbinding()]
	Param (
		[Parameter(mandatory=$true,position=0)][string]$Path,
		[Parameter(mandatory=$true,position=1)][string]$Value
	)
	Write-Verbose ('Start testing if "' + $Value + '" exists in "' + $Path + '"')
	$compare = ((Get-ItemProperty -ErrorAction SilentlyContinue -LiteralPath $Path).psbase.members) | %{$_.name} | compare $Value -IncludeEqual -ExcludeDifferent -ErrorAction SilentlyContinue
	If($compare.SideIndicator -like "==") {
		Return $true
		Write-Verbose ('True')
	} Else { 
		Return $false
		Write-Verbose ('False')
	}
}
#-

# Optimization routine for NICs
Function Optimize-NIC {
	[cmdletbinding()]
	Param (
		[Parameter(mandatory=$true,position=0)][string]$Path,
		[Parameter(mandatory=$true,position=1)][string]$Key,
		[Parameter(mandatory=$true,position=2)][string]$Value
	)
	Write-Verbose ('Path      : ' + $Path)
	Write-Verbose ('Key       : ' + $Key)
	Write-Verbose ('Value     : ' + $Value)
	$ReturnValue = $false
	if (Test-RegPathValue $Path $Key) {
		Write-Host -NoNewLine -ForegroundColor Gray ('              - Changing "' + $Key + '" to "' + $Value + '"')
		Set-ItemProperty -Path $Path -Name $Key -Value $Value
		Write-Host -ForegroundColor Green (" (done)`r")
		$ReturnValue = $true
	}
	Return $ReturnValue
}
#-

# Custom Registry function
function SetRegValue {
	[cmdletbinding()]
	Param (
		[string]$Path,
		[string]$Name,
		$Value,
		[string]$Type,
		[switch]$SkipIfNotExist=$false
	)
	if ($SkipIfNotExist) {
		if (Test-Path -Path "$Path") {
			Set-ItemProperty -Path $Path  -Name $Name -Value $Value -Type $Type
			if ( (Get-ItemProperty -Path $Path -Name $Name).$Name.ToString() -eq $Value) {
				Write-Host -ForegroundColor Green " (done)`r"
			} else {
				Write-Host -ForegroundColor Red " (failed)`r"
			}
		} else { 
			Write-Host -ForegroundColor Yellow " (skipped)`r"
		}
	} else {
		if (-Not(Test-Path -Path "$Path")) {
			New-Item -Path "$($Path.TrimEnd($Path.Split('\')[-1]))" -Name "$($Path.Split('\')[-1])" -Force | Out-Null
		}
		Set-ItemProperty -Path $Path  -Name $Name -Value $Value -Type $Type 
		if ( (Get-ItemProperty -Path $Path -Name $Name).$Name.ToString() -eq $Value) {
			Write-Host -ForegroundColor Green " (done)`r"
		} else {
			Write-Host -ForegroundColor Red " (failed)`r"
		}
	}
}
#- 

# -------------------------------------------------------------------------------
# ------------------------------ Get OS Info ------------------------------------
$varWinVer = $null
try { [string]$varWinVer = (Get-CimInstance Win32_OperatingSystem).Version }
catch { [string]$varWinVer = [System.Environment]::OSVersion.Version | % {"{0}.{1}.{2}" -f $_.Major,$_.Minor,$_.Build} }

switch ($varWinVer.SubString(0,4)){
	"5.0." { $varWinVer = "5.0" }	# 5.0 Windows 2000
	"5.1." { $varWinVer = "5.1" }	# 5.1 Windows XP
	"5.2." { $varWinVer = "5.2" }	# 5.2 Windows 2003/2003R2/XP Pro x64
	"6.0." { $varWinVer = "6.0" }	# 6.0 Windows 2008/Vista
	"6.1." { $varWinVer = "6.1" }	# 6.0 Windows 2008R2/7
	"6.2." { $varWinVer = "6.2" }	# 6.2 Windows 2012/8
	"6.3." { $varWinVer = "6.3" }	# 6.3 Windows 2012R2/8.1
	"6.4." { $varWinVer = "6.4" }	# 6.4 Windows 10 (Beta)
	"10.0" { $varWinVer = "10.0" }	# 10.0 Windows 10
}
$objComputerSystem = Get-CimInstance CIM_ComputerSystem
$strManufacturer = $objComputerSystem.Manufacturer
$strModel = $objComputerSystem.Model
$isVM = ($strManufacturer.Tolower() -match 'microsoft') -or ($strManufacturer.Tolower() -match 'vmware') -or ($strManufacturer.Tolower() -match 'xen')
$objWMI = $null
#-

# Setting HKEY_USERS
$null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS
$null = New-PSDrive -Name HKCR -PSProvider Registry -Root Registry::HKEY_CLASSES_ROOT
$null = New-PSDrive -Name HKCC -PSProvider Registry -Root Registry::HKEY_CURRENT_CONFIG
#-

# Displaying OS info
$OSInfo = Get-WmiObject Win32_OperatingSystem | Select-Object PSComputerName,Version,OSArchitecture,Caption
Write-Host "`r"
Write-Host "`r"
Write-Host -ForegroundColor Yellow "== SYSTEM INFO ======================================================`r"
Write-Host -ForegroundColor Gray "Manufacturer   : $strManufacturer`r"
Write-Host -ForegroundColor Gray "Model          : $strModel`r"
Write-Host -ForegroundColor Gray "Virt. Machine  : $isVM`r" 
$OSInfo | Format-List -Property *
# Check if OS is supported with this script.
if (-not (($OSInfo.Version.StartsWith("6.1")) -Or 
($OSInfo.Version.StartsWith("6.2")) -Or
($OSInfo.Version.StartsWith("6.3")) -Or
($OSInfo.Version.StartsWith("6.4")) -Or
($OSInfo.Version.StartsWith("10.0")))) {
	Write-Host -ForegroundColor Blue "NOTE: This OS is NOT supported/tested in combination with this script`r"
	Write-Host "`r"
}
if ($OSInfo.Version.StartsWith("6.4")) {
	Write-Host -ForegroundColor Blue "NOTE: This is an Beta OS!`r"
	Write-Host "`r"
}
Write-Host -ForegroundColor Yellow "== Start Optimizing your system =====================================`r"
Write-Host "`r"
#-

# -------------------------------------------------------------------------------

# Ensure the script runs with elevated privileges
Use-RunAs
# -

# Remove unblock dialogue for sub processes
Unblock-Files -Filepath $strPathDevConx86 
Unblock-Files -Filepath $strPathDevConx64 
Unblock-Files -Filepath $strPathnvspbindx86 
Unblock-Files -Filepath $strPathnvspbindx64 
# -


# Disable TCP/IP task offloading 
# http://support.citrix.com/article/CTX117491
if ($blnDisableTaskOffload) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disabling TCP/IP task offloading"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"  -Name "DisableTaskOffload" -Value "1" -Type "DWORD"
}
# -

# Disable TSO and DMA on XenTools
# http://support.citrix.com/article/CTX125157
if ($blnDisableTSODMAXenTools) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable TSO and DMA on XenTools"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\xenevtchn" -Name "SetFlags" -Value "196608" -Type "DWORD" -SkipIfNotExist
}
# -

# Hide Hard Error Messages
if ($blnHideHardErrorMessages) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Set Hide Hard Error Messages"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Windows" -Name "ErrorMode" -Value "2" -Type DWORD 
}
# -

# Disable CIFS Change Notifications
if ($blnDisableCIFSChangeNotifications) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable CIFS Change Notifications"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRemoteRecursiveEvents" -Value "1" -Type "DWORD"
}
# -

# Increase Service Startup Timeout
if ($blnIncreaseServiceStartupTimeout) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Increase Service Startup Timeout"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "ServicesPipeTimeout" -Value "180000" -Type "DWORD"
}
# -

# Disable Logon Screensaver
if ($blnDisableLogonScreensaver) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Logon Screensaver"
	Write-Verbose ''
	SetRegValue -Path "HKU:\.DEFAULT\Control Panel\Desktop" -Name "ScreenSaveActive" -Value "0" -Type "String"
}
# -

# Disable Bug Check Memory Dump
if ($blnDisableMemoryDumps) {
	#Inform user
	Write-Host -ForegroundColor White "Disable Bug Check Memory Dump"
	Write-Verbose ''
	Write-Host -NoNewLine -ForegroundColor Gray " - 1/3"
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "CrashDumpEnabled" -Value "0" -Type "DWORD"
	Write-Host -NoNewLine -ForegroundColor Gray " - 2/3"
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "LogEvent" -Value "0" -Type "DWORD"
	Write-Host -NoNewLine -ForegroundColor Gray " - 3/3"
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "SendAlert" -Value "0" -Type "DWORD"
}
# -

# Increases the UDP packet size to 1500 bytes for FastSend
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2040065
if ($blnIncreaseFastSendDatagramThreshold) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Increasing UDP FastSend threshold"
	Write-Verbose ''
	if ($strManufacturer.Tolower() -match 'vmware') {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\afd\Parameters" -Name "FastSendDatagramThreshold" -Value "1500" -Type "DWORD" -SkipIfNotExist
	} else {
		Write-Host -ForegroundColor Yellow " (skipped, no VMware VM)`r"
	}
}
# -

 # Set multiplication factor to the default UDP scavenge value (MaxEndpointCountMult)
# http://support.microsoft.com/kb/2685007/en-us
if (($blnSetMaxEndpointCountMult) -and ($varWinVer.StartsWith("6.1"))) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Set multiplication factor to the default UDP scavenge value"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BFE\Parameters" -Name "MaxEndpointCountMult" -Value "0x10" -Type "DWORD" -SkipIfNotExist
}
# -

# Disable IPv6 completely
# http://social.technet.microsoft.com/wiki/contents/articles/10130.root-causes-for-slow-boots-and-logons-sbsl.aspx
if ($blnDisableIPv6) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable IPv6 completely"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TcpIp6\Parameters" -Name "DisabledComponents" -Value "0xffffffff" -Type "DWORD"
}
# -

# Hide PVS status icon 
# http://forums.citrix.com/thread.jspa?threadID=273278
if ($blnHidePVSstatusicon) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Hide PVS status icon"
	Write-Verbose ''
	if (Test-Path -Path "HKLM:\SOFTWARE\Citrix\ProvisioningServices") {
		SetRegValue -Path "HKLM:\SOFTWARE\Citrix\ProvisioningServices\StatusTray" -Name "ShowIcon" -Value "0" -Type "DWORD"
	} else { Write-Host -ForegroundColor Yellow " (skipped)`r" } 		
}
# -

# Hide VMware tools icon
# http://www.blackmanticore.com/c84d61182fa782af965e0abf2d82d6e6
if ($blnHideVMwareToolsIcon) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Hide VMware tools icon"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -Name "ShowTray" -Value "0" -Type "DWORD" -SkipIfNotExist
}
# -

# Disable VMware debug driver 
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1007652
if ($blnDisableVMwareDebugDriver) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable VMware debug driver"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\services\vmdebug" -Name "Start" -Value "4" -Type "DWORD" -SkipIfNotExist
}
# -

# Disable Receive Side Scaling (RSS)
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2055853
# http://support.microsoft.com/kb/951037/en-us
if ($blnDisableRSS) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Receive Side Scaling (RSS)"
	Write-Verbose ''
	$cmd = 'netsh.exe'
	$arg = 'int tcp set global rss=disable'
	$Output = Run-Program -Command $cmd -ArgumentList $arg
}
# -

# Set the selected Power schema
# http://blogs.technet.com/b/richardsmith/archive/2007/11/29/powercfg-useful-if-you-know-the-guids.aspx
# http://blogs.msdn.com/b/aaronsaikovski/archive/2011/04/21/setting-your-machine-power-plan-via-powershell.aspx
if ($blnPowerSchema) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White ('Set power schema')
	Write-Verbose ''
	switch ($intPreferredPlan) {
		1 { $strNewPowerGUID ="8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" }
		2 { $strNewPowerGUID ="381b4222-f694-41f0-9685-ff5bb260df2e" }
		3 { $strNewPowerGUID ="a1841308-3541-4fab-bc81-f71556f20b4a" }
	}
	Write-Verbose 'Trying to set Power schema'
	Write-Verbose ('NewPowerGUID: ' + $strNewPowerGUID)
	$cmd = 'powercfg'
	$arg = '-S ' + $strNewPowerGUID
	$Output = Run-Program -Command $cmd -ArgumentList $arg
}
# -

#  Disable Offline Files
if ($blnDisableOfflineFiles){
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Offline Files"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" -Name "Enabled" -Value "0" -Type "DWORD"
}
# -

#  Disable Windows Autoupdate
if ($blnDisableWindowsAutoupdate) {
	#Inform user
	Write-Host -ForegroundColor White "Disable Windows Autoupdate"
	Write-Verbose ''
	Write-Host -NoNewline -ForegroundColor Gray " - 1/4" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "NoAutoUpdate" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 2/4" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "AUOptions" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 3/4" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "ScheduledInstallDay" -Value "0" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 4/4" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "ScheduledInstallTime" -Value "3" -Type "DWORD"
}
# -

#  Disable Defrag BootOptimizeFunction
if ($blnDisableDefragBootOptimize) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Defrag BootOptimizeFunction"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" -Name "Enable" -Value "N" -Type "String"
}
# -

#  Disable Background Layout Service
if ($blnDisableBackgroundLayout) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Background Layout Service"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" -Name "EnableAutoLayout" -Value "0" -Type "DWORD"
}
# -

#  Disable Last Access Timestamp
if ($blnDisableLastAccessTimestamp) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Last Access Timestamp"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsDisableLastAccessUpdate" -Value "1" -Type "DWORD"
}
# -

#  Disable Hibernate
if ($blnDisableHibernate) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Hibernate"
	Write-Verbose ''
	if ($varWinVer.StartsWith("5")) {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "Heuristics" -Value ([byte[]](0x05,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3f,0x42,0x0f,0x00)) -Type "Binary"
	} Elseif ($varWinVer.StartsWith("6.0")) {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "Heuristics" -Value ([byte[]](0x06,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x3F,0x42,0x0F,0x00)) -Type "Binary"
	} Elseif ($varWinVer.StartsWith("6.1")) {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Value "0" -Type "DWORD"
	} Elseif (($varWinVer.StartsWith("6.2")) -or ($varWinVer.StartsWith("6.3")) -or ($varWinVer.StartsWith("6.4")) -or ($varWinVer.StartsWith("10.0"))) {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value "0" -Type "DWORD"
	}
}
# -

#  Reduce DedicatedDumpFile DumpFileSize to 2MB
if ($blnReduceDedicatedDumpFile2M) {
	#Inform user
	Write-Host -ForegroundColor White "Reduce DedicatedDumpFile DumpFileSize to 2MB"
	Write-Verbose ''
	Write-Host -NoNewline -ForegroundColor Gray " - 1/2" 
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DumpFileSize" -Value "2" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 2/2" 
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "IgnorePagefileSize" -Value "1" -Type "DWORD"
}
# -

#  Disable Move to Recycle Bin
if ($blnDisableMovetoRecBin) {
	#Inform user
	if ($varWinVer.StartsWith("5")) {
		Write-Host -ForegroundColor White "Disable Move to Recycle Bin"
		Write-Verbose ''
		Write-Host -NoNewline -ForegroundColor Gray " - 1/2" 
		SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\BitBucket" -Name "UseGlobalSettings" -Value "1" -Type "DWORD"
		Write-Host -NoNewline -ForegroundColor Gray " - 2/2" 
		SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\BitBucket" -Name "NukeOnDelete" -Value "1" -Type "DWORD"
	} else {
		Write-Host -NoNewline -ForegroundColor White "Disable Move to Recycle Bin"
		Write-Verbose ''
		SetRegValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecycleFiles" -Value "1" -Type "DWORD"
	}
}
# -

#  Reduce Event Log Size
if ($blnReduceEventLogSize) {
	#Inform user
	Write-Host -ForegroundColor White "Reduce Event Log Size to" $intEventLogSize "kb"
	if ($intEventLogSize -is [int]) {
		$strValue = (([Math]::Round($intEventLogSize) ) * 1024).ToString()
		Write-Host -NoNewline -ForegroundColor Gray " - Application Log"
		Write-Verbose ''
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Application" -Name "MaxSize" -Value "$strValue" -Type "DWORD"
		Write-Host -NoNewline -ForegroundColor Gray " - Security Log"
		Write-Verbose ''
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security" -Name "MaxSize" -Value "$strValue" -Type "DWORD"
		Write-Host -NoNewline -ForegroundColor Gray " - System Log"
		Write-Verbose ''
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\System" -Name "MaxSize" -Value "$strValue" -Type "DWORD"
	} else {
		Write-Host -ForegroundColor Red " (error, no integer specified)`r"
	}
}
# -

#  Redirect the Event logs
if ($blnRedirectEventLog) {
	#Inform user
	Write-Host -ForegroundColor White "Redirect the Event Logs to" $strRedirectEventLogPath
	Write-Host -NoNewline -ForegroundColor Gray " - Application Log"
	SetRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" -Name "File" -Value ($strRedirectEventLogPath + 'Application.evtx') -Type "String"
	Write-Host -NoNewline -ForegroundColor Gray " - Security Log"
	SetRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" -Name "File" -Value ($strRedirectEventLogPath + 'Security.evtx') -Type "String"
	Write-Host -NoNewline -ForegroundColor Gray " - Setup Log"
	SetRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" -Name "File" -Value ($strRedirectEventLogPath + 'Setup.evtx') -Type "String"
	Write-Host -NoNewline -ForegroundColor Gray " - System Log"
	SetRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" -Name "File" -Value ($strRedirectEventLogPath + 'System.evtx') -Type "String"
}
# -

#  Reduce IE Temp File
if ($blnReduceIETempFile) {
	#Inform user
	Write-Host -ForegroundColor White "Reduce IE Temp File"
	Write-Host -NoNewline -ForegroundColor Gray " - 1/9" 
	SetRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content" -Name "CacheLimit" -Value "400" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 2/9" 
	SetRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Content" -Name "CacheLimit" -Value "400" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 3/9" 
	SetRegValue -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content" -Name "CacheLimit" -Value "400" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 4/9" 
	SetRegValue -Path "HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Content" -Name "CacheLimit" -Value "400" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 5/9" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" -Name "Paths" -Value "4" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 6/9" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path1" -Name "CacheLimit" -Value "100" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 7/9" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path2" -Name "CacheLimit" -Value "100" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 8/9" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path3" -Name "CacheLimit" -Value "100" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 9/9" 
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path4" -Name "CacheLimit" -Value "100" -Type "DWORD"
}
# -

#  Disable Clear Page File at Shutdown
if ($blnDisableClearPageFileAtShutdown) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Clear Page File at Shutdown"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value "0" -Type "DWORD"
}
# -

if ($blnSetPagefile) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White ('Set Page file to "' + $strPageFile + '\pagefile.sys" With initial size of: ' + $intPageFileInitialSize + 'MB, and maximum size of: ' + $intPageFileMaximumSize + 'MB')
	Write-Verbose ''
	if ($intPageFileMaximumSize -ge $intPageFileInitialSize) {
		$Out = (Set-PageFile $strPageFile $intPageFileInitialSize $intPageFileMaximumSize)
		if ($Out.exitcode -eq 1) {
			Write-Host -ForegroundColor Red " (error)`r"
			Write-Host -ForegroundColor Red " - The PageFile was not set correctly`r"
		}
		Elseif (($Out.exitcode -eq 0) -and ($Out.modified)) {
			Write-Host -ForegroundColor Green " (done)`r"
		}
		Elseif (($Out.exitcode -eq 0) -and ($Out.modified -eq $false)) {
			Write-Host -ForegroundColor Yellow " (skipped)`r"
			Write-Host -ForegroundColor Yellow " - Already set as specified.`r"
		}
		Else {
			Write-Host -ForegroundColor Magenta " (unknown)`r"
			Write-Verbose ('Exitcode: ' + $Out.exitcode)
			Write-Verbose ('Modified: ' + $Out.modified)
		}
	}
	else { Write-Host -ForegroundColor Yellow " (skipped) PageFile size incorrect.`r" }
}


#  Disable Machine Account Password Changes
if ($blnDisableMachinePasswordChanges) {
	#Inform user
	Write-Host -ForegroundColor White "Disable Machine Account Password Changes"
	Write-Host -NoNewline -ForegroundColor Gray " - 1/2" 
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "DisablePasswordChange" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 1/2" 
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "MaximumPasswordAge" -Value "30" -Type "DWORD"
}
# -
#  Disable Windows Defender
if ($blnDisableWindowsDefender) {
	#Inform user
	Write-Host -ForegroundColor White "Disable Windows Defender"
	if (($varWinVer.StartsWith("6.1")) -or ($varWinVer.StartsWith("6.2"))) {
		Write-Host -NoNewline -ForegroundColor Gray " - 1/2" 
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name "Start" -Value "4" -Type "DWORD"
		Write-Host -NoNewline -ForegroundColor Gray " - 2/2" 
		SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Windows Defender" -Value "" -Type "ExpandString"
	} Elseif (($varWinVer.StartsWith("6.3")) -or ($varWinVer.StartsWith("6.4")) -or ($varWinVer.StartsWith("10.0"))) {
		$cmd = 'schtasks.exe'
		$arrDisableDefTasks = @(
			"microsoft\windows\windows Defender\Windows Defender Cache Maintenance",
			"microsoft\windows\windows Defender\Windows Defender Cleanup",
			"microsoft\windows\windows Defender\Windows Defender Scheduled Scan",
			"microsoft\windows\windows Defender\Windows Defender Verification"
		)
		foreach ($task in $arrDisableDefTasks) {
			Write-Host -NoNewline -ForegroundColor Gray " -" $task
			$arg = '/change /tn "' + $task + '" /Disable'

			$Output = Run-Program -Command $cmd -ArgumentList $arg
		}
	} Else { Write-Host -ForegroundColor Red " (skipped) not a supported OS`r" }
}
# -
#  Run ngen.exe executeQueuedItems
#  http://poshcode.org/5136
if ($blnOptimizeDotNet) {
	#Inform user
	Write-Host -ForegroundColor White "Optimize .Net (can take a couple of minutes)`r"
	#Remove-Item variable:frameworks
	# get all framework paths (adding 64-bit if necessary):
	$frameworks = @("$env:SystemRoot\Microsoft.NET\Framework")
	if (Test-Path "$env:SystemRoot\Microsoft.NET\Framework64") {
		$frameworks += "$env:SystemRoot\Microsoft.NET\Framework64"
	}
	ForEach ($framework in $frameworks) {
		# find the latest version of NGEN.EXE in the current framework path:
		$ngen_path = Join-Path (Join-Path $framework -childPath (gci $framework | where { ($_.PSIsContainer) -and (Test-Path (Join-Path $_.FullName -childPath "ngen.exe")) } | Sort Name -Descending | Select -First 1).Name) -childPath "ngen.exe"

		Write-Host -NoNewline -ForegroundColor Gray " - $ngen_path update /force /queue"
		$process = Start-Process $ngen_path -ArgumentList "update /force /queue" -Wait -Passthru
		if ($process.ExitCode -eq 0) {
			Write-Host -ForegroundColor Green " (done)`r"
		} Else {
			Write-Host -ForegroundColor Red " (error) [$($process.ExitCode)]`r"
		}
		
		Write-Host -NoNewline -ForegroundColor Gray " - $ngen_path executeQueuedItems"
		$process = Start-Process $ngen_path -ArgumentList "executeQueuedItems" -Wait -Passthru
		if ($process.ExitCode -eq 0) {
			Write-Host -ForegroundColor Green " (done)`r"
		} Else {
			Write-Host -ForegroundColor Red " (error) [$($process.ExitCode)]`r"
		}
	}
	if (($varWinVer.StartsWith("6.2")) -Or ($varWinVer.StartsWith("6.3")) -Or ($varWinVer.StartsWith("6.4")) -or ($varWinVer.StartsWith("10.0"))) {
		Write-Host -ForegroundColor White "Running .Net tasks`r"
		$arrNetTasks = @()
		$arrNetTasks += ,@('Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319')
		if ([System.IntPtr]::Size -eq 8) {
			$arrNetTasks += ,@('Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64')
		}
		$cmd = 'schtasks.exe'
		foreach ($task in $arrNetTasks) {
			Write-Host -NoNewline -ForegroundColor Gray (" - " + $task)
			$arg = '/run /tn "' + $task + '"'
			$Output = Run-Program -Command $cmd -ArgumentList $arg -Show
			if (($Output.ExitCode -eq 0) -Or ($Output.ExitCode -eq 3010)) {
				Write-Host -ForegroundColor Green " (done)`r"
			} Elseif (($Output.ExitCode -ge 1) -And (($Output.Stderr).Contains("The specified task name")) -And (($Output.Stderr).Contains("does not exist in the system"))) {
				Write-Host -ForegroundColor Yellow " (skipped) does not exist`r"
			} Elseif ($Output.ExitCode -ge 1) {
				Write-Host -ForegroundColor Red " (error) [$($Output.ExitCode)]`r"
				Write-Verbose ('Output: ' + $Value.Stdout)
				Write-Verbose ('Error:  ' + $Value.Stderr)
			}
		}
	}
}
# -

#  Disable Touch Keyboard and Handwriting Panel Service service
if ($blnDisableTabletInputSvc) {
       #Inform user
       Write-Host -NoNewline -ForegroundColor White "Disable Touch Keyboard and Handwriting Panel Service service"
       $reg = "TabletInputService"
       Set-Service -Name $reg -StartupType Disabled
       if ((Get-WmiObject Win32_Service -filter "Name='$reg'").StartMode -eq "Disabled") {
             Write-Host -ForegroundColor Green " (done)`r"
       } Else { Write-Host -ForegroundColor Red " (error)`r" }
}
#- 

#  Enable intermediate buffering for Local Hard Drive Cache
#  http://support.citrix.com/article/CTX126042
if ($blnIntermediateBuffering) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Enable intermediate buffering for Local Hard Drive Cache"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BNIStack\Parameters" -Name "WcHDNoIntermediateBuffering" -Value "2" -Type "DWORD"
}
# -

#  Improve storage performance of PVS streamed target devices on XenServer / VMWare
if ($blnWcRamConfiguration) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Improve storage performance of PVS streamed target devices on XenServer / VMWare"
	Write-Verbose ''
	if ($isVM) {
		SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\BNIStack\Parameters" -Name "WcRamConfiguration" -Value "1" -Type "DWORD"
	} else {
		Write-Host -ForegroundColor Yellow " (skipped)`r"
	}
}
# -

# Tuning SMB 1.0 is required in mixed environments where 
# Windows 2012 / 8 and Windows 2003 or earlier systems connect.
if (($blnSMB1Tuning) -and (($varWinVer.StartsWith("6.2")) -or ($varWinVer.StartsWith("6.3")))) {
	#Inform user
	Write-Host -ForegroundColor White "Tuning SMB 1.0"
	Write-Host -NoNewline -ForegroundColor Gray " - 1/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "MaxCmds" -Value "2048" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 2/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SystemCurrentControlSet\Services\MRxSmb\Parameters" -Name "MultiUserEnabled" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 3/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRemoteRecursiveEvents" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 4/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanserver\Parameters" -Name "MaxWorkItems" -Value "8192" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 5/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanserver\Parameters" -Name "MaxMpxCt" -Value "2048" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 6/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanserver\Parameters" -Name "MaxRawWorkItems" -Value "512" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 7/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanserver\Parameters" -Name "MaxFreeConnections" -Value "100" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " - 8/8"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanserver\Parameters" -Name "MinFreeConnections" -Value "32" -Type "DWORD"
}
# -

# Tuning SMB 2.0 is required in mixed environments where 
# Windows 2012 / 8 and Windows 2008 / 2008 R2 systems connect.
if (($blnSMB2Tuning) -and (($varWinVer.StartsWith("6.2")) -or ($varWinVer.StartsWith("6.3")))) {
	#Inform user
	Write-Host -ForegroundColor White "Tuning SMB 2.0"
	Write-Host -NoNewline -ForegroundColor Gray " 1/3"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanworkstation\Parameters" -Name "DisableBandwidthThrottling" -Value "1" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " 2/3"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Lanmanworkstation\Parameters" -Name "DisableLargeMtu" -Value "0" -Type "DWORD"
	Write-Host -NoNewline -ForegroundColor Gray " 3/3"
	Write-Verbose ''
	SetRegValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRemoteRecursiveEvents" -Value "1" -Type "DWORD"
}
# -

#  When brokering occurs wile still logging off
#  http://support.citrix.com/article/CTX138551
if ($blnDelayLogoffNotificationEnabled) {
	#Inform user
	Write-Host -ForegroundColor White "Enable Delay Logoff Notification"
	Write-Host -NoNewline -ForegroundColor Gray " - x64 "
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Wow6432Node\Citrix\PortICA" -Name "DelayLogoffNotificationEnabled" -Value "1" -Type "DWORD" -SkipIfNotExist
	Write-Host -NoNewline -ForegroundColor Gray " - x86 "
	Write-Verbose ''
	SetRegValue -Path "HKLM:\SOFTWARE\Citrix\PortICA" -Name "DelayLogoffNotificationEnabled" -Value "1" -Type "DWORD" -SkipIfNotExist
}
# -

#  Enable Remote Registry service
if ($blnEnableRemoteRegistrySvc) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Enable Remote Registry service"
	Write-Verbose ''
	$reg = "RemoteRegistry"
	Set-Service -Name $reg -StartupType Automatic
	if ((Get-WmiObject Win32_Service -filter "Name='$reg'").StartMode -eq "Auto") {
		Write-Host -ForegroundColor Green " (done)`r"
	} Else { Write-Host -ForegroundColor Red " (error)`r" }
}
#-

#  Remove OneDrive on Windows 10
if ($blnRemoveOneDrive) {
	#Inform user
	Write-Host -ForegroundColor White "Removing OneDrive"
	if ($varWinVer.StartsWith("10.0")) {
		Write-Host -NoNewline -ForegroundColor Gray "  - Stopping OneDrive"
		Write-Verbose ''
		$cmd = $env:SystemRoot + '\System32\taskkill.exe'
		$arg = '/f /im OneDrive.exe'
		$Output = Run-Program -Command $cmd -ArgumentList $arg
		Start-Sleep -s 5
		if (Test-Path ($env:SystemRoot + "\SysWOW64\OneDriveSetup.exe")) {
			Write-Host -NoNewline -ForegroundColor Gray "  - Removing x64"
			$cmd = $env:SystemRoot + '\SysWOW64\OneDriveSetup.exe'
			$arg = '/uninstall'
			$Output = Run-Program -Command $cmd -ArgumentList $arg
			Start-Sleep -s 4
			Remove-Item $cmd -Force | Out-Null
		} Elseif (Test-Path "%SystemRoot%\System32\OneDriveSetup.exe") {
			Write-Host -NoNewline -ForegroundColor Gray "  - Removing x86"
			$cmd = $env:SystemRoot + '\System32\OneDriveSetup.exe'
			$arg = '/uninstall'
			$Output = Run-Program -Command $cmd -ArgumentList $arg
			Start-Sleep -s 4
			Remove-Item $cmd -Force | Out-Null
		}
	} Else { Write-Host -ForegroundColor Yellow " (skipped) not a supported OS`r" }
}
#-

#  Disable Boot Log
if ($blnDisableBootLog) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Boot Log"
	if (($varWinVer.StartsWith("6.2")) -or ($varWinVer.StartsWith("6.3")) -Or ($varWinVer.StartsWith("6.4")) -or ($varWinVer.StartsWith("10.0"))) {
		Write-Verbose ''
		$cmd = 'bcdedit.exe'
		$arg = '/set {default} bootlog no'
		$Output = Run-Program -Command $cmd -ArgumentList $arg
	} Else { Write-Host -ForegroundColor Yellow " (skipped) not a supported OS`r" }
}
#-

#  Disable Boot Animation
if ($blnDisableBootAnimation) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Disable Boot Animation"
	if (($varWinVer.StartsWith("6.2")) -or ($varWinVer.StartsWith("6.3")) -Or ($varWinVer.StartsWith("6.4")) -or ($varWinVer.StartsWith("10.0"))) {
		Write-Verbose ''
		$cmd = 'bcdedit.exe'
		$arg = '/set {default} quietboot yes'
		$Output = Run-Program -Command $cmd -ArgumentList $arg
	} Else { Write-Host -ForegroundColor Yellow " (skipped) not a supported OS`r" }
}
#-

#  Remove certain windows features, set features above
if ($blnFeaturesToDisable) {
	#Inform user
	Write-Host -ForegroundColor White "Remove windows features (can take a couple of minutes):`r"
	Write-Verbose ''
	$cmd = 'dism.exe'
	foreach ($feature in $arrFeatures) {
		Write-Host -NoNewline -ForegroundColor Gray " -" $feature[2]
		Switch ($feature[0]) {
			"NoChange" {
				Write-Host -ForegroundColor Yellow " (skipped) No changes made`r"
			}
			"Remove" {
				if ($feature[1] -Match ($varWinVer)) {
					$arg = '/online /Disable-Feature /Quiet /NoRestart /FeatureName:'+$feature[2]
					$Output = Run-Program -Command $cmd -ArgumentList $arg
				} Else { Write-Host -ForegroundColor Yellow " (skipped) not applicable to this OS`r" }
			}
		}
	}
}
#-

#  Disable certain windows scheduled tasks, set scheduled tasks above
if ($blnTasksToDisable) {
	#Inform user
	Write-Host -ForegroundColor White "Disable certain windows scheduled tasks:`r"
	Write-Verbose ''
	foreach ($task in $arrTasks) {
		if ($task[1] -Match ($varWinVer)) {
			Write-Host -NoNewline -ForegroundColor Gray " -" $task[2]
			Switch ($task[0]) {
			
				"NoChange" {
					Write-Host -ForegroundColor Yellow " (skipped) No changes made`r"
				}
				"Disable" {
					$cmd = 'schtasks.exe'
					$arg = '/change /tn "' + $task[2] + '" /Disable'
					$Output = Run-Program -Command $cmd -ArgumentList $arg -Show
						Write-Verbose ('Variable cmd: ' + $cmd)
						Write-Verbose ('Variable arg: ' + $arg)
						Write-Verbose ('Variable output: ' + $Output)
					if (($Output.ExitCode -eq 0) -Or ($Output.ExitCode -eq 3010)) {
						Write-Host -ForegroundColor Green " (done)`r"
					} Elseif (($Output.ExitCode -ge 1) -And (($Output.Stderr).Contains("The specified task name")) -And (($Output.Stderr).Contains("does not exist in the system"))) {
						Write-Host -ForegroundColor Yellow " (skipped) does not exist`r"
					} Elseif ($Output.ExitCode -ge 1) {
						Write-Host -ForegroundColor Red " (error) [$($Output.ExitCode)]`r"
						Write-Verbose ('Output: ' + $Value.Stdout)
						Write-Verbose ('Error:  ' + $Value.Stderr)
					}
					
				}
				"DisableAsSystem" {
					if (Test-Path $strPathPsExec) {
						$arg = '-accepteula -s schtasks.exe /change /tn "' + $task[2] + '" /Disable'
						$Output = Run-Program -Command $strPathPsExec -ArgumentList $arg -Show
						Write-Verbose ('Variable cmd: ' + $strPathPsExec)
						Write-Verbose ('Variable arg: ' + $arg)
						Write-Verbose ('Variable output: ' + $Output)
						if (($Output.ExitCode -eq 0) -Or ($Output.ExitCode -eq 3010)) {
							Write-Host -ForegroundColor Green " (done)`r"
						} Elseif (($Output.ExitCode -ge 1) -And (($Output.Stderr).Contains("The specified task name")) -And (($Output.Stderr).Contains("does not exist in the system"))) {
							Write-Host -ForegroundColor Yellow " (skipped) does not exist`r"
						} Elseif ($Output.ExitCode -ge 1) {
							Write-Host -ForegroundColor Red " (error) [$($Output.ExitCode)]`r"
							Write-Verbose ('Output: ' + $Value.Stdout)
							Write-Verbose ('Error:  ' + $Value.Stderr)
						}
					} Else { Write-Host -ForegroundColor Red " (error) PsExec.exe not found!`r" }
				
				}
			}
		}
	}
}
#-

# Remove Appx Apps
if ($blnAppxAppsToRemove) {
	#Inform user
	Write-Host -ForegroundColor White "Removing Appx Apps"
	Write-Verbose ''	
	foreach ($AppxApp in $arrAppxApps) {
		Write-Host -NoNewline -ForegroundColor Gray " -" $AppxApp[2]
		Switch ($AppxApp[0]) {
			"NoChange" {
				Write-Host -ForegroundColor Yellow " (skipped) No changes made`r"
			}
			"Remove" {
				if ($AppxApp[1] -Match ($varWinVer)) {
					Try {
						Get-AppxPackage | Where-Object {$_.PackageFullName -like $AppxApp[2]} | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
						Get-AppxPackage -allusers | Where-Object {$_.PackageFullName -like $AppxApp[2]} | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
						Get-AppxProvisionedPackage -Online | Where-Object {$_.packagename -like $AppxApp[2]} | Remove-ProvisionedAppxPackage -Online -ErrorAction SilentlyContinue | Out-Null
					} Catch {
						Write-Host -ForegroundColor Red (" (error)`r")
						$FailedItem = $_.Exception.ItemName
						Write-Verbose ('Caught an error')
						Write-Verbose ('ErrorMessage: ' + $ErrorMessage)
						Write-Verbose ('FailedItem: ' + $FailedItem)
						continue
					} Finally {
						Write-Host -ForegroundColor Green (" (done)`r")
					}

				} Else { Write-Host -ForegroundColor Yellow " (skipped) not applicable to this OS`r" }
				
			}
	
		}
	}
}
#-
# Start defrag
if ($blnStartDefrag) {
	#Inform user
	Write-Host -ForegroundColor White "Start defrag`r"
	if ((((Get-Service -Name "defragsvc").Status) -eq "Running") -Or (((Get-Service -Name "defragsvc").Status) -eq "Stopped")) {
		ForEach ($DriveLetter in $arrDrivesToDefrag) {
			if ($DriveLetter -ne "") {
				Write-Host -NoNewLine -ForegroundColor Gray (" - Starting defrag on drive " + $DriveLetter)
				$process = Start-Process 'defrag.exe' -ArgumentList ($DriveLetter + ' /U /H') -Wait -Passthru
				if ($process.ExitCode -eq 0) {
					Write-Host -ForegroundColor Green " (done)`r"
				} Else { Write-Host -ForegroundColor Red " (error) ExitCode: $process.ExitCode`r" }
			}
		}
	} Else { Write-Host -ForegroundColor Yellow (" -Skipped, Defrag- / Optimize drives Service is not running`r") }
}
##-

#  Disable certain windows services, set services above
if ($blnServicesToDisable) {
	#Inform user
	Write-Host -ForegroundColor White "Disable certain windows services:`r"
	foreach ($service in $arrServices) {
		Write-Host -NoNewline -ForegroundColor Gray " -" $service[2]
		if ($service[1] -Match ($varWinVer)) {
			if (ServiceExists([string]$service[2])) {
			
				Switch ($service[0]) {
					"NoChange" { 
						Write-Host -ForegroundColor Yellow " (skipped) No changes made`r" 
					}
					"Disabled" {
						Stop-Service -Name $service[2] -Force # 'Force' parameter stops dependent services 
						if ((get-service $service[2]).Status -eq "Stopped") {
							Write-Host -NoNewline -ForegroundColor Blue " (stopped)"
							Write-Verbose ''
							
							Set-Service -Name $service[2] -StartupType Disabled
							if ((Get-WmiObject Win32_Service -filter "Name='$($service[2])'").StartMode -eq "Disabled") {
								Write-Host -ForegroundColor Green " (done) Service Disabled`r"
							} Else { Write-Host -ForegroundColor Red " (error) Disabling failed`r" }
							
						} Else { Write-Host -ForegroundColor Red " (error) Failed stopping`r" }
					}
				}
			} Else { Write-Host -ForegroundColor Yellow " (skipped) Service not found`r" }
		} Else { Write-Host -ForegroundColor Yellow " (skipped) Service not applicable for this OS`r" }
	}
}
#-

#  Determine if the 'Citrix Network Stack Interface Driver' service is started
#  http://support.citrix.com/article/CTX138199
$blnRunningInvDisk = $false
Write-Host -NoNewLine -ForegroundColor White "The 'bnistack' service is "
Write-Verbose ''
$arrbnistackService = Get-Service bnistack -ErrorAction SilentlyContinue
if ($arrbnistackService.Length -eq 0) {
    Write-Host -ForegroundColor Yellow "NOT installed.`r"
} else {
    if ($arrbnistackService.Status -eq "Running") {
        #Inform user
        Write-Host -ForegroundColor Yellow "running.`r"
        #The vDisk is streamed via PVS
        $blnRunningInvDisk = $true
	    #Inform user
	    Write-Host -NoNewline -ForegroundColor White "This vDisk is streamed via PVS in: "  
	    #Determine write cache type - https://support.citrix.com/article/CTX122224
	    [int]$intWriteCacheType = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\bnistack\PvsAgent" -ErrorAction SilentlyContinue).WriteCacheType
	    [string]$strWriteCacheType = "(Unknown)"
	    switch ($intWriteCacheType) {
		    0 {$strWriteCacheType = "Private Mode"}
		    1 {$strWriteCacheType = "Standard Mode: Server Disk"}
		    2 {$strWriteCacheType = "Standard Mode: Server Disk Encrypted"}
		    3 {$strWriteCacheType = "Standard Mode: RAM"}
		    4 {$strWriteCacheType = "Standard Mode: Hard Disk"}
		    5 {$strWriteCacheType = "Standard Mode: Hard Disk Encrypted"}
		    6 {$strWriteCacheType = "Standard Mode: RAM Disk"}
		    7 {$strWriteCacheType = "Standard Mode: Difference Disk"}
			8 {$strWriteCacheType = "Standard Mode: Hard Disk Persistent"}
			9 {$strWriteCacheType = "Standard Mode: RAM with overflow to Disk"}
	    }
	Write-Host -ForegroundColor Yellow ($strWriteCacheType + ' [' + $intWriteCacheType + ']`r')
    } else {
        #Inform user
        Write-Host -ForegroundColor Yellow "installed`r"
		Write-Host -ForegroundColor Gray " - This disk is not streamed via PVS.`r"
    }
}


if ($blnRemoveHiddenNICs) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Removing hidden NIC"
	Write-Verbose ''
	$objGhostNICs = gwmi win32_NetworkAdapter | ?{(
		$_.Description.Tolower() -like ("Intel(R) PRO/1000 MT Network Connection".Tolower()) -or 
		$_.Description.Tolower() -like ("Intel(R) 82574L Gigabit Network Connection".Tolower()) -or 
		$_.Description.Tolower() -like ("vmxnet3 Ethernet Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Citrix PV Ethernet Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Citrix PV Network Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Realtek RTL8139C+ Fast Ethernet NIC".Tolower()) -or 
		$_.Description.Tolower() -like ("Microsoft Virtual Machine Bus Network Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Intel 21140-Based PCI Fast Ethernet Adapter (Emulated)".Tolower())) -and 
		$_.Installed -like "True" -and 
		$_.MACAddress -eq $null 
	}
	if ($objGhostNICs -ne $null){
		Write-Host -ForegroundColor White ":`r"
		Foreach ($NIC in $objGhostNICs) {
			$objNICproperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f ([Int]$NIC.DeviceID))) -ErrorAction SilentlyContinue)
			$objHardwareProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Enum\{0}" -f $objNICproperties.DeviceInstanceID) -ErrorAction SilentlyContinue)
			$objNetworkProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Network\{0}\{1}\Connection" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $objNICproperties.NetCfgInstanceId) -ErrorAction SilentlyContinue)
			Write-Host ""
			Write-Host -NoNewline -ForegroundColor White "   ID     : "; Write-Host -ForegroundColor Yellow ( "{0:D4}`r" -f [Int]$NIC.DeviceID)
			Write-Host -NoNewline -ForegroundColor White "   Network: "; Write-Host -ForegroundColor Yellow $objNetworkProperties.Name "`r"
			Write-Host -NoNewline -ForegroundColor White "   NIC    : "; Write-Host -ForegroundColor Yellow $NIC.Name "`r"
			Write-Host -ForegroundColor White "   Actions`r"
			Write-Host -NoNewline -ForegroundColor Red ("            - Trying to remove")
			#Remove hardware with devcon - http://support.microsoft.com/kb/311272/en-us
			if ([System.IntPtr]::Size -eq 4) {
				# 32-Bit
				$cmd = $strPathDevConx86
				$arg = ('remove "@{0}"' -f $objNICproperties.DeviceInstanceID)
				$Output = Run-Program -Command $cmd -ArgumentList $arg
			} else {
				# 64-Bit
				$cmd = $strPathDevConx64
				$arg = ('remove "@{0}"' -f $objNICproperties.DeviceInstanceID)
				$Output = Run-Program -Command $cmd -ArgumentList $arg
			}
			Write-Host ""
		}
	} Else {
		Write-Host -ForegroundColor Yellow " (skipped) None found`r"
	}
}
	
#- optimize that NIC!
if ($blnOptimizeNICs) {
	#Inform user
	Write-Host -NoNewline -ForegroundColor White "Optimizing NIC"
	$objNICs = gwmi win32_NetworkAdapter | ?{(
		$_.Description.Tolower() -like ("Intel(R) PRO/1000 MT Network Connection".Tolower()) -or 
		$_.Description.Tolower() -like ("Intel(R) 82574L Gigabit Network Connection".Tolower()) -or 
		$_.Description.Tolower() -like ("vmxnet3 Ethernet Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Citrix PV Ethernet Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Citrix PV Network Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Realtek RTL8139C+ Fast Ethernet NIC".Tolower()) -or 
		$_.Description.Tolower() -like ("Microsoft Virtual Machine Bus Network Adapter".Tolower()) -or 
		$_.Description.Tolower() -like ("Intel 21140-Based PCI Fast Ethernet Adapter (Emulated)".Tolower())) -and 
		$_.Installed -like "True" -and 
		$_.MACAddress -ne $null
	}
	if ($objNICs -ne $null){
		Write-Host -ForegroundColor White ":`r"
		Foreach ($NIC in $objNICs) {
			$intNICid = [Int]$NIC.DeviceID
			$strRegPath = ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f $intNICid))
			$objNICproperties = (Get-ItemProperty -Path $strRegPath -ErrorAction SilentlyContinue)
			$objHardwareProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Enum\{0}" -f $objNICproperties.DeviceInstanceID) -ErrorAction SilentlyContinue)
			$objNetworkProperties = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Network\{0}\{1}\Connection" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", $objNICproperties.NetCfgInstanceId) -ErrorAction SilentlyContinue)
			Write-Host ""
			Write-Host -NoNewline -ForegroundColor White "   ID     : "; Write-Host -ForegroundColor Yellow ( "{0:D4}`r" -f $intNICid)
			Write-Host -NoNewline -ForegroundColor White "   Network: "; Write-Host -ForegroundColor Yellow $objNetworkProperties.Name "`r"
			Write-Host -NoNewline -ForegroundColor White "   NIC    : "; Write-Host -ForegroundColor Yellow $NIC.Name "`r"
			Write-Host -ForegroundColor White "   Actions:`r"
			# - Increase ARP cache lifespan
			if ($blnIncreaseARPCacheLifespan) {
				Write-Host -NoNewline -ForegroundColor Gray ("            - Increase ARP cache lifespan")
				$cmd = 'netsh.exe'
				$arg = 'interface ipv4 set interface ' + $NIC.interfaceIndex + ' basereachable=600000'
				$Output = Run-Program -Command $cmd -ArgumentList $arg
			}	
			# - remove IPv6 binding 
			if ($blnRemoveIPv6Binding) {
			    #Determine if IPv6 is bind
				$objNIClinkage = (Get-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0}\{1}\Linkage" -f "{4D36E972-E325-11CE-BFC1-08002BE10318}", ( "{0:D4}" -f [Int]$NIC.DeviceID)) -ErrorAction SilentlyContinue)
				Write-Host -NoNewline -ForegroundColor Gray ("            - Removing IPv6 binding")
				If( $objNIClinkage.UpperBind -contains "Tcpip6") {
	                # Remove IPv6 binding with nvspbind - http://archive.msdn.microsoft.com/nvspbind
					if ([System.IntPtr]::Size -eq 4) {
						$cmd = $strPathnvspbindx86
						$arg = '/d ' + $objNICproperties.NetCfgInstanceId + ' ms_tcpip6'
						$Output = Run-Program -Command $cmd -ArgumentList $arg
					} else {
						$cmd = $strPathnvspbindx64
						$arg = '/d ' + $objNICproperties.NetCfgInstanceId + ' ms_tcpip6'
						$Output = Run-Program -Command $cmd -ArgumentList $arg
					}
				} Else { Write-Host -ForegroundColor Yellow " (skipped)`r" }
			}
			$blnOptimized = $false
			$blnNicNotFound = $false
			Write-Host -NoNewLine -ForegroundColor Gray "            - Start optimizing" 
			#Determine NIC type
			Write-Verbose ($objNICproperties.DriverDesc.ToLower())
			switch ($objNICproperties.DriverDesc.ToLower()) {
				#E1000 (VMware)
				"Intel(R) PRO/1000 MT Network Connection".Tolower() {
					Write-Verbose ('Starting With "Intel(R) PRO/1000 MT Network Connection"')
					Write-Host -NoNewLine -ForegroundColor Yellow "NOTE: This NIC is not supported for use with PVS!"
					# --- Flow Control ---
					$strRegistryKeyName = "*FlowControl"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Interrupt Moderation ---
					$strRegistryKeyName = "*InterruptModeration"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- IPv4 Checksum Offload ---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Jumbo Packet ---
					$strRegistryKeyName = "*JumboPacket"
					$blnEnabled = $false
					$strValue = "1514"
					# 1514 - Disabled (Default)
					# 4088 - 4088 Bytes
					# 9014 - 9014 Bytes (Alteon)
					# 16128 - 16128 Bytes
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload (IPv4) ---
					$strRegistryKeyName = "*LsoV1IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Priority & VLAN ---
					$strRegistryKeyName = "*PriorityVLANTag"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Priority & VLAN Disabled
					# 1 - Priority Enabled
					# 2 - VLAN Enabled
					# 3 - Priority & VLAN Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Receive Buffers ---
					$strRegistryKeyName = "*ReceiveBuffers"
					$blnEnabled = $false
					$strValue = "256"
					# Value between 80 and 2048 with steps of 8, default is 256
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Link Speed & Duplex ---
					$strRegistryKeyName = "*SpeedDuplex"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Auto Negotiation (default)
					# 1 -  10 Mbps Half Duplex
					# 2 -  10 Mbps Full Duplex
					# 3 - 100 Mbps Half Duplex
					# 4 - 100 Mbps Full Duplex
					# 5 - 1000 Mbps Full Duplex
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Transmit Buffers ---
					$strRegistryKeyName = "*TransmitBuffers"
					$blnEnabled = $false
					$strValue = "512"
					# Value between 80 and 2048 with steps of 8, default is 512
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)							
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Adaptive Inter-Frame Spacing ---
					$strRegistryKeyName = "AdaptiveIFS"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Interrupt Moderation Rate ---
					$strRegistryKeyName = "ITR"
					$blnEnabled = $false
					$strValue = "65535"
					# 65535 - Adaptive (default)
					# 3600 - Extreme
					# 2000 - High
					# 950 - Medium
					# 400 - Low
					# 200 - Minimal
					# 0 - Off
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Number of Coalesce Buffers ---
					$strRegistryKeyName = "NumCoalesceBuffers"
					$blnEnabled = $false
					$strValue = "128"
					# Value between 16 and 768, default is 128
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}
				#Intel(R) 82574L (E1000 VMware)
				"Intel(R) 82574L Gigabit Network Connection".Tolower() {
					Write-Verbose ('Starting With "Intel(R) 82574L Gigabit Network Connection"')
					Write-Host -NoNewLine -ForegroundColor Yellow "NOTE: This NIC is not supported for use with PVS!"
					# --- Flow Control ---
					$strRegistryKeyName = "*FlowControl" 
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Interrupt Moderation ---
					$strRegistryKeyName = "*InterruptModeration"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- IPv4 Checksum Offload ---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Jumbo Packet ---
					$strRegistryKeyName = "*JumboPacket"
					$blnEnabled = $false
					$strValue = "1514"
					# 1514 - Disabled (Default)
					# 4088 - 4088 Bytes
					# 9014 - 9014 Bytes (Alteon)
					# 16128 - 16128 Bytes
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload (IPv4) ---
					$strRegistryKeyName = "*LsoV2IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Large Send Offload (IPv6) ---
					$strRegistryKeyName = "*LsoV2IPv6"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Priority & VLAN ---
					$strRegistryKeyName = "*PriorityVLANTag"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Priority & VLAN Disabled
					# 1 - Priority Enabled
					# 2 - VLAN Enabled
					# 3 - Priority & VLAN Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Receive Buffers ---
					$strRegistryKeyName = "*ReceiveBuffers"
					$blnEnabled = $false
					$strValue = "256"
					# Value between 80 and 2048 with steps of 8, default is 256
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Link Speed & Duplex ---
					$strRegistryKeyName = "*SpeedDuplex"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Auto Negotiation (default)
					# 1 -  10 Mbps Half Duplex
					# 2 -  10 Mbps Full Duplex
					# 3 - 100 Mbps Half Duplex
					# 4 - 100 Mbps Full Duplex
					# 5 - 1000 Mbps Full Duplex
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- TCP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Transmit Buffers ---
					$strRegistryKeyName = "*TransmitBuffers"
					$blnEnabled = $false
					$strValue = "512"
					# Value between 80 and 2048 with steps of 8, default is 512
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)							
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled 
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)							
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Adaptive Inter-Frame Spacing ---
					$strRegistryKeyName = "AdaptiveIFS"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Interrupt Moderation Rate ---
					$strRegistryKeyName = "ITR"
					$blnEnabled = $false
					$strValue = "65535"
					# 65535 - Adaptive (default)
					# 3600 - Extreme
					# 2000 - High
					# 950 - Medium
					# 400 - Low
					# 200 - Minimal
					# 0 - Off
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}
				#vmxnet3 (VMware)
				"vmxnet3 Ethernet Adapter".Tolower() {
					Write-Verbose ('Starting With "vmxnet3 Ethernet Adapter"')
					# --- Enable adaptive rx ring sizing ---
					$strRegistryKeyName = "EnableAdaptiveRing"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Enable adaptive rx ring sizing ---
					$strRegistryKeyName = "*EnableAdaptiveRing"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Interrupt Moderation ---
					$strRegistryKeyName = "*InterruptModeration"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- IPv4 Checksum Offload ---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Jumbo Packet ---
					$strRegistryKeyName = "*JumboPacket"
					$blnEnabled = $false
					$strValue = "1514"
					# 1514 - Standard 1500 (default)
					# 9014 - Jumbo 9000
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- IPv4 TSO Offload ---
					$strRegistryKeyName = "*LsoV1IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- IPv4 Giant TSO Offload ---
					$strRegistryKeyName = "*LsoV2IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- IPv6 TCP Segmentation Offload ---
					$strRegistryKeyName = "*LsoV2IPv6"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					#--- Maximum number of RSS Processors ---
					$strRegistryKeyName = "*MaxRssProcessors"
					$blnEnabled = $false
					$strValue = "8"
					# 1 - 1
					# 2 - 2
					# 4 - 4
					# 8 - 8 (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Priority / VLAN tag ---
					$strRegistryKeyName = "*PriorityVLANTag"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Priority & VLAN Disabled
					# 1 - Priority Enabled
					# 2 - VLAN Enabled (default)
					# 3 - Priority & VLAN Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- RSS ---
					$strRegistryKeyName = "*RSS"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default) 
					# 1 - Enabled 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- RSS Base Processor Number ---
					$strRegistryKeyName = "*RssBaseProcNumber"
					$blnEnabled = $false
					$strValue = "63"
					# value between 0 and 63, default is 63 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Speed / Duplex ---
					$strRegistryKeyName = "*SpeedDuplex"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Auto Negotiation (default)
					# 1 -  10 Mbps Half Duplex
					# 2 -  10 Mbps Full Duplex
					# 3 - 100 Mbps Half Duplex
					# 4 - 100 Mbps Full Duplex
					# 5 - 1.0 Gbps Half Duplex
					# 6 - 1.0 Gbps Full Duplex
					# 7 -  10 Gbps Full Duplex
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- TCP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Wake on magic packet ---
					$strRegistryKeyName = "*WakeOnMagicPacket"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)							
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Wake on pattern match ---
					$strRegistryKeyName = "*WakeOnPattern"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)	
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Wake-on-LAN ---
					$strRegistryKeyName = "EnableWakeOnLan"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Rx Ring #1 Size ---
					$strRegistryKeyName = "MaxRxRing1Length"
					$blnEnabled = $false
					$strValue = "512"
					# 32 - 32
					# 64 - 64
					# 128 - 128
					# 256 - 256
					# 512 - 512 (default)
					# 630 - 630
					# 768 - 768
					# 896 - 896
					# 1024 - 1024
					# 2048 - 2048
					# 4096 - 4096
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Rx Ring #2 Size ---
					$strRegistryKeyName = "MaxRxRing2Length"
					$blnEnabled = $false
					$strValue = "32"
					# 32 - 32 (default)
					# 64 - 64
					# 128 - 128
					# 256 - 256
					# 512 - 512 
					# 1024 - 1024
					# 2048 - 2048
					# 4096 - 4096
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Max Tx Queues ---
					$strRegistryKeyName = "MaxTxQueues"
					$blnEnabled = $false
					$strValue = "1"
					# 1 - 1 (default)
					# 2 - 2
					# 4 - 4
					# 8 - 8
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Tx Ring Size ---
					$strRegistryKeyName = "MaxTxRingLength"
					$blnEnabled = $false
					$strValue = "512"
					# 32 - 32 
					# 64 - 64
					# 128 - 128
					# 256 - 256
					# 512 - 512 (default)
					# 1024 - 1024
					# 2048 - 2048
					# 4096 - 4096
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Rx Buffers ---
					$strRegistryKeyName = "NumRxBuffersLarge"
					$blnEnabled = $false
					$strValue = "768"
					# 64 - 64
					# 128 - 128
					# 256 - 256
					# 512 - 512 
					# 768 - 768 (default)
					# 1024 - 1024
					# 2048 - 2048
					# 3072 - 3072
					# 4096 - 4096							
					# 8192 - 8192
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Small Rx Buffers ---
					$strRegistryKeyName = "NumRxBuffersSmall"
					$blnEnabled = $false
					$strValue = "1024"
					# 64 - 64
					# 128 - 128
					# 256 - 256
					# 512 - 512 
					# 768 - 768 
					# 1024 - 1024 (default)
					# 2048 - 2048
					# 3072 - 3072
					# 4096 - 4096							
					# 8192 - 8192
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Offload IP Options ---
					$strRegistryKeyName = "OffloadIpOptions"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Offload TCP Options ---
					$strRegistryKeyName = "OffloadTcpOptions"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Offload tagged traffic ---
					$strRegistryKeyName = "OffloadVlanEncap"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Receive Throttle ----
					$strRegistryKeyName = "RxThrottle"
					$blnEnabled = $false
					$strValue = "0"
					# Value between 0 and 5000 with steps of 10 - default is 0
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- VLAN ID ---
					$strRegistryKeyName = "VlanId"
					$blnEnabled = $false
					$strValue = "0"
					# Value between 0 and 4095 - default is 0
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
							
				}
				#Xennet6 (XenServer)
				"Citrix PV Ethernet Adapter".Tolower() {
					Write-Verbose ('Starting With "Citrix PV Ethernet Adapter"')
					# --- IPv4 Checksum Offload---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload Version 2 (IPv4) ---
					$strRegistryKeyName = "*LSOv2IPv4"
					$strValue = "0"
					$blnEnabled = $true
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Receive Offload (IPv4) ---
					$strRegistryKeyName = "LROIPv4"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- "Correct TCP/UDP Checksum Value ---
					$strRegistryKeyName = "NeedChecksumValue"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}		
				
				#Xennet7 (XenServer)
				"Citrix PV Network Adapter".Tolower() {
					Write-Verbose ('Starting With "Citrix PV Network Adapter"')
					# --- IPv4 Checksum Offload---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload Version 2 (IPv4) ---
					$strRegistryKeyName = "*LSOV2IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload Version 2 (IPv6) ---
					$strRegistryKeyName = "*LSOV2IPv6"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- TCP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- UDP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Enabled (Transmit Only)
					# 2 - Enabled (Receive Only)
					# 3 - Enabled (Transmit and Receive) (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Receive Offload (IPv4) ---
					$strRegistryKeyName = "LROIPv4"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- Large Receive Offload (IPv6) ---
					$strRegistryKeyName = "LROIPv6"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					# --- "Correct TCP/UDP Checksum Value ---
					$strRegistryKeyName = "NeedChecksumValue"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}										
				#RTL8139a (XenServer)
				"Realtek RTL8139C+ Fast Ethernet NIC".Tolower() {
					Write-Verbose ('Starting With "Realtek RTL8139C+ Fast Ethernet NIC"')
					# --- Link Speed/Duplex Mode ---
					$strRegistryKeyName = "DuplexMode"
					$blnEnabled = $false
					$strValue = "1"
					# 1 - Auto Negotiation (default)
					# 2 -  10Mbps/Half Duplex
					# 3 -  10Mbps/Full Duplex
					# 4 - 100Mbps/Half Duplex
					# 5 - 100Mbps/Full Duplex
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
	
					# --- Link Down Power Saving ---
					$strRegistryKeyName = "EnableLDPS"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
	
					# --- Optimal Performance ---
					$strRegistryKeyName = "OptimalPerf"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled 
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Receive Buffer Size ---
					$strRegistryKeyName = "RxBufLen"
					$blnEnabled = $false
					$strValue = "3"
							# 0 - 8K bytes
							# 1 - 16K bytes
							# 2 - 32K bytes
							# 3 - 64K bytes (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}
				#vmbus (Hyper-V)
				"Microsoft Virtual Machine Bus Network Adapter".Tolower() {
					Write-Verbose ('Starting With "Microsoft Virtual Machine Bus Network Adapter"')
					#--- IPv4 Checksum Offload ---
					$strRegistryKeyName = "*IPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					#--- Jumbo Packet ---
					$strRegistryKeyName = "*JumboPacket"
					$blnEnabled = $false
					$strValue = "1514"
					# 1514 - Disabled (Default)
					# 4088 - 4088 Bytes
					# 9014 - 9014 Bytes
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					#--- Large Send Offload Version 2 (IPv4) ---
					$strRegistryKeyName = "*LsoV2IPv4"
					$blnEnabled = $true
					$strValue = "0"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Large Send Offload Version 2 (IPv6) ---
					$strRegistryKeyName = "*LsoV2IPv6"
					$blnEnabled = $false
					$strValue = "1"
					# 0 - Disabled 
					# 1 - Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					#--- TCP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					#--- TCP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*TCPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "3"
					# 0 - Disabled
					# 1 - Tx Enabled
					# 2 - Rx Enabled
					# 3 - Tx and Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					#--- UDP Checksum Offload (IPv4) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv4"
					$blnEnabled = $false
					$strValue = "2"
					# 0 - Disabled
					# 2 - Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
					
					#--- UDP Checksum Offload (IPv6) ---
					$strRegistryKeyName = "*UDPChecksumOffloadIPv6"
					$blnEnabled = $false
					$strValue = "2"
					# 0 - Disabled
					# 2 - Rx Enabled (default)
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				}
				#Intel 21140  (Hyper-V legacy)
				"Intel 21140-Based PCI Fast Ethernet Adapter (Emulated)".Tolower() {
					Write-Verbose ('Starting With "Intel 21140-Based PCI Fast Ethernet Adapter (Emulated)"')
					# --- Burst Length ---
					$strRegistryKeyName = "BurstLength"
					$blnEnabled = $false
					$strValue = "10"
					# 1 - 1 DWORD
					# 2 - 2 DWORDS
					# 4 - 4 DWORDS
					# 8 - 8 DWORDS
					# 10 - 16 DWORDS (default)
					# 20 - 32 DWORDS
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Connection Type ---
					$strRegistryKeyName = "ConnectionType"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - AutoSense (default)
					# 8 - 100BaseTx
					# 9 - 100BaseTx Full Duplex
					# 0A - 100BaseT4
					# 0B - 100BaseFx
					# 0C - 100BaseFx Full Duplex
					# 2 - 10BaseT (Twisted Pair)
					# 3 - 10BaseT Full Duplex
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Extra Receive Buffers ---
					$strRegistryKeyName = "ExtraReceiveBuffers"
					$blnEnabled = $false
					$strValue = "10"
					# 0 -   0
					# 10 -  16 (default)
					# 20 -  32
					# 40 -  64
					# 80 - 128
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Extra Receive Packets ---
					$strRegistryKeyName = "ExtraReceivePackets"
					$blnEnabled = $false
					$strValue = "64"
					# 10 - 16
					# 20 - 32
					# 40 - 64
					# 64 - 100 (default)
					# 128 - 200
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# ---Interrupt Mitigation ---
					$strRegistryKeyName = "InterruptMitigation"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Memory Read Multiple ---
					$strRegistryKeyName = "MemoryReadMultiple"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Network Address ---
					$strRegistryKeyName = "NetworkAddress"
					$blnEnabled = $false
					$strValue = ""
					#String value
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Process Transmit First ---
					$strRegistryKeyName = "ProcessTransmitFirst"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Receive Buffers ---
					$strRegistryKeyName = "ReceiveBuffers"
					$blnEnabled = $false
					$strValue = "30"
					# 8 -  8
					# 10 - 16
					# 20 - 32
					# 30 - 48 (default)
					# 40 - 64
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Store And Forward ---
					$strRegistryKeyName = "StoreAndForward"
					$blnEnabled = $false
					$strValue = "0"
					# 0 - Disabled (default)
					# 1 - Enabled"
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# ---Transmit Threshold ---
					$strRegistryKeyName = "TransmitThreshold"
					$blnEnabled = $false
					$strValue = "60"
					# 48 -   72 bytes
					# 60 -   96 bytes (default)
					# 80 -  128 bytes
					# A0 -  160 bytes
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Transmit Threshold 100Mbps---
					$strRegistryKeyName = "TransmitThreshold100"
					$blnEnabled = $false
					$strValue = "200"
					# 80 -  128 bytes
					# 100 -  256 bytes
					# 200 -  512 bytes (default)
					# 400 - 1024 bytes
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Underrun Max Retries---
					$strRegistryKeyName = "UnderrunRetry"
					$blnEnabled = $false
					$strValue = "2"
					# 2 -  2 (default)
					# 4 -  4
					# 6 -  6
					# 8 -  8
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
	
					# --- Underrun Threshold ---
					$strRegistryKeyName = "UnderrunThreshold"
					$blnEnabled = $false
					$strValue = "0A"
					# 0A -  10 (default)
					# 14 -  20
					# 32 -  50
					# 64 - 100
					if ($blnEnabled -eq $true) {
						if ($blnOptimized -eq $false) { Write-Host "`r" }
						$blnOptimized = (Optimize-NIC -Path $strRegPath -Key $strRegistryKeyName -Value $strValue)
					}
				} 
				default { $blnNicNotFound = $true }
			}
			Write-Verbose "End optimizing"
			if ($blnNicNotFound -eq $true) {
				# No optimizations for this NIC available
				Write-Host -ForegroundColor Yellow " (skipped) No optimizations for this NIC available`r"
			} Elseif (($blnNicNotFound -eq $false) -And ($blnOptimized -eq $false)) {
				# Optimizations available but non executed
				Write-Host -ForegroundColor Yellow " (skipped) No optimizations enabled for this NIC`r"
			} Elseif (($blnNicNotFound -eq $false) -And ($blnOptimized -eq $true)) {
				# Optimizations available and executed
				Write-Host -ForegroundColor Green "              - Finished`r"
			}
			Write-Host ""
		}	
	} Else { Write-Host -ForegroundColor Yellow " (skipped) None found`r" }
}
Write-Host "`r"
Write-Host -ForegroundColor Yellow "== FINISHED =========================================================`r"
Write-Host "`r"
Write-Host "`r"
# Request the user to reboot the machine
Write-Host -NoNewLine -ForegroundColor White "Please "
Write-Host -NoNewLine -ForegroundColor Yellow "reboot"
Write-Host -ForegroundColor White " the machine for the changes to take effect.`r"
Write-Host "`r"
Write-Host "`r"

# Stop writing to log file
Stop-Transcript | out-null

Exit 3010
