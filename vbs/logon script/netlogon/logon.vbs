OPTION Explicit

On Error Resume Next

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'*****Declare & Instantiate PUBLIC constants, variables and arrays*****
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dim arScriptExtensions
arScriptExtensions = array("vbs", "vbe", "wsf", "ps1", "bat", "cmd", "js", "jse", "reg")

'*************Values extracted from WSH INTRINSICS ********************
Dim obFS, obNet, obShell
Dim dtGrpName
Dim obDSE
Dim sCmpName, sUsrName
Dim bLogging
Dim sStarttime, sEndtime, sRuntime

sStarttime = Now

' Searches for /debug switch in script arguments and enables screen output if present
If fnIsArgSet(WScript.Arguments, "/debug") Then
	bLogging = True
Else
	bLogging = False
End If

If bLogging Then
	WScript.Echo "Starting Script - " & Time
End If

If bLogging Then
	WScript.Echo "Starting 'Object Creation' - " & Time
End If
Set obFS = CreateObject("Scripting.FileSystemObject")		
Set obNet = CreateObject("WScript.Network")
Set obShell = CreateObject("WScript.Shell")
Set dtGrpName = CreateObject("Scripting.Dictionary") 
Set obDSE = GetObject("LDAP://rootDSE")
If bLogging Then
	WScript.Echo "COMPLETE 'Object Creation' - " & Time
End If

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dim sAllUserProfile, sFileCheckFullPath

sAllUserProfile = obShell.ExpandEnvironmentStrings("%ALLUSERSPROFILE%")
sFileCheckFullPath = sAllUserProfile & "\AppSense\Environment Manager\configuration.aemp"

If obFS.fileExists(sFileCheckFullPath) Then
	If obShell.RegRead ("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName") = "Microsoft Windows XP" Then 
		If bLogging Then
			WScript.Echo vbTab & "AppSense installed, System is Windows XP Continue Login Script"
		End If
	Else
		If bLogging Then
			WScript.Echo vbTab & "Exiting script due to AppSense configuration found at: " & sFileCheckFullPath
		End If
                WScript.Quit 0
	End If
End If
 
 '***AppSense configuration is not installed Continue with regular Login script***
'----------------------------------------------------------------------

'sUsrName uses the replace function to normalize the value for use with xxxx accounts.
If bLogging Then
	WScript.Echo "Starting 'Identify User and Computer Name' - " & Time
End If
sUsrName = fnGetNormalizedUsrName(obNet.UserName)
sCmpName = lcase(obNet.ComputerName)

If bLogging Then
	WScript.Echo vbTab & "User Name: " & sUsrName
	WScript.Echo vbTab & "Computer Name: " & sCmpName	
	WScript.Echo "COMPLETE 'Identify User and Computer Name' - " & Time
End If

'*************COMBO Values for DOMAIN WIDE Folder Locations ************
'Dynamically build domain folder path information so that the script can locate all dependand utilities and files
Dim sDomainGrpDir, sDomainIncDir, sDomainUsrDir, sDomainUtilDir, sDomainWscDir
Dim sScriptDir

If bLogging Then
	WScript.Echo "Starting 'Building Domain Wide Folder Locations to Process' - " & Time
End If
sScriptDir = obFS.GetParentFolderName(WScript.ScriptFullName) & "\"
sDomainIncDir = sScriptDir & "domain"
sDomainGrpDir = sDomainIncDir & "\grp"
sDomainUsrDir = sDomainIncDir & "\usr"
sDomainUtilDir = sDomainIncDir & "\utl"
sDomainWscDir = sDomainIncDir & "\wsc"
If bLogging Then
	WScript.Echo "COMPLETE 'Building Folder Locations to Process' - " & Time
End If

'**********Values extracted from ACTIVE DIRECTORY ATTRIBUTES ***********

'Query Active Directory to gather relevant computer attributes
If bLogging Then
	WScript.Echo "Starting 'Query AD for Computer Attributes' - " & Time
End If
Dim sCmpAdPath, sCmpLocation, sCmpDN
sCmpAdPath = fnGetADsPath("computer")
If sCmpAdPath = "" Then
	'If first attempt to get ADsPath failed, wait 5 seconds and try again
	If bLogging Then
		WScript.Echo vbTab & "FAILED, First Attempt 'Query AD for Computer Attributes' - " & Time
	End If
	WScript.Sleep 5000
	sCmpAdPath = fnGetADsPath("computer")
End If
Dim obCmp : Set obCmp = GetObject(sCmpAdPath)
sCmpLocation = obCmp.location
sCmpDN = obCmp.distinguishedName
If fnIsArgSet(WScript.Arguments, "/noscriptfromfield") Then
	If InStr(lcase(sCmpDN), "ou=field") <> 0 Then
		If bLogging Then
			WScript.Echo vbTab & "'No script execution from field' switch found - Aborting script execution"
		End If
		WScript.Quit
	End If
End If
If bLogging Then
	WScript.Echo vbTab & "Computer dn: " & sCmpDN
	WScript.Echo vbTab & "Computer location: " & sCmpLocation
End If
If bLogging Then
	WScript.Echo "COMPETE 'Query AD for Computer Attributes' - " & Time
End If

'Query Active Directory to gather relevant user attributes
If bLogging Then
	WScript.Echo "Starting 'Query AD for User Attributes' - " & Time
End If
Dim sUsrAdPath, sUsrDn, sUsrLocation, sUsrCountry
sUsrAdPath = fnGetADsPath("user")
If bLogging Then
   	WScript.Echo vbTab & "User adspath: " & sUsrAdPath
End If

If sUsrAdPath = "" Then
	'If first attempt to get ADsPath failed, wait 5 seconds and try again
	If bLogging Then
    	WScript.Echo vbTab & "FAILED, First Attempt 'Query AD for User Attributes' - " & Time
  	End If
	WScript.Sleep 5000
	sUsrAdPath = fnGetADsPath("user")
End If
Dim obUsr : Set obUsr = GetObject(sUsrAdPath)
sUsrDn = obUsr.distinguishedName
sUsrLocation = lcase(obUsr.l)
sUsrCountry = lcase(obUsr.c)

' Temporarily added to set all Canadian staff to map dirves using data under Calgary folder. Added 12/13/2011
If sUsrCountry = "ca" Then
	sUsrLocation = "calgary"
End If

If bLogging Then
	WScript.Echo vbTab & "User dn: " & sUsrDn
End If
If bLogging Then
	WScript.Echo "COMPLETE 'Query AD for User Attributes' - " & Time
End If

'***************COMBO Values for SITE SPECIFIC folder locations***********
'Dynamically build site wide folder path information so that the script can locate all dependand utilities and files. The fnGetConfigLocation
'function is dependant upon Active Directory information so this code block MUST follow the Active Directory Queries.
Dim sSiteGrpDir, sSiteIncDir, sSiteUtilDir

If bLogging Then
	WScript.Echo "Starting 'Building Site Specific Folder Locations to Process' - " & Time
End If
sSiteIncDir = sScriptDir & "locations\" & fnGetConfigLocation()
sSiteUtilDir = sSiteIncDir & "\utl"
sSiteGrpDir = sSiteIncDir & "\grp"
If bLogging Then
	WScript.Echo vbTab & "Site folder selected: " & sSiteIncDir
	WScript.Echo "COMPLETE 'Building Site Specific Folder Locations to Process' - " & Time
End If



'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'*******************Begin Script Execution*****************************
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

on error resume next

	If bLogging Then
		WScript.Echo "Starting 'sbMapNetworkDrives' - " & Time
	End If
	Call sbMapNetworkDrives(sDomainIncDir & "\config.xml", sSiteIncDir & "\config.xml")
	If bLogging Then
		WScript.Echo "COMPLETE 'sbMapNetworkDrives' - " & Time
	End If
	
	If fnIsDesktop() Then
		If bLogging Then
			WScript.Echo "Starting 'sbBuildSysutil' - " & Time
		End If
		Call sbBuildSysutil()
		If bLogging Then
			WScript.Echo "COMPLETE 'sbBuildSysutil' - " & Time
		End If

		If bLogging Then
			WScript.Echo "Starting 'sbProcessUsrUtls' - " & Time
		End If
		Call sbProcessUsrUtls()
		If bLogging Then
			WScript.Echo "COMPLETE 'sbProcessUsrUtls' - " & Time
		End If

 		If bLogging Then
 			WScript.Echo "Starting 'sbProcessGrpUtls' - " & Time
			wscript.echo vbTab & "Domain GRP Folder: " & sDomainGrpDir
			wscript.echo vbTab & "Site GRP Folder: " & sSiteGrpDir
 		End If
 		Call sbProcessGrpUtls (sDomainGrpDir, sSiteGrpDir)
 		If bLogging Then
 			WScript.Echo "COMPLETE 'sbProcessGrpUtls' - " & Time
 		End If

		If bLogging Then
			WScript.Echo "Starting 'sbProcessUtls' - " & Time
			wscript.echo vbTab & "Domain UTIL Folder: " & sDomainUtilDir
			wscript.echo vbTab & "Site UTIL Folder: " & sSiteUtilDir
		End If
		Call sbProcessUtls(sDomainUtilDir, sSiteUtilDir)
		If bLogging Then
			WScript.Echo "COMPLETE 'sbProcessUtls' - " & Time
		End If
	End If

Set obUsr = Nothing
Set obCmp = Nothing

ON ERROR GOTO 0

If bLogging Then
	WScript.Echo "Ending Script - " & Time
End If

sEndtime = Now
sRuntime = DateDiff("s", sStarttime, sEndtime)

' Write execution time to Application Log
obShell.LogEvent 4, "Execution time for logon.vbs: " & sRuntime & " seconds"

If bLogging Then
	WScript.Echo VbCrLf & "Total Script Execution time: " & sRuntime & " seconds"
End If

WScript.Quit	

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'**************Build Functions and subroutines*************************
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

'----------
Sub sbBuildSysutil
'----------
'This subroutine builds the sysutil directory structure on the workstation. The sysutil directory structure is where com objects And
'utility scripts are stored on the local computer.

on error resume next
	Dim sSysDrive : sSysDrive = obShell.ExpandEnvironmentStrings("%SYSTEMDRIVE%")

	If Not obFS.folderExists(sSysDrive & "\sysutil") Then obFS.createFolder sSysDrive & "\sysutil"
	If Not obFS.folderExists(sSysDrive & "\sysutil\batch") Then obFS.createFolder sSysDrive & "\sysutil\batch"
	If Not obFS.folderExists(sSysDrive & "\sysutil\com") Then obFS.createFolder sSysDrive & "\sysutil\com"
	If Not obFS.folderExists(sSysDrive & "\sysutil\bin") Then obFS.createFolder sSysDrive & "\sysutil\bin"
	If Not obFS.folderExists(sSysDrive & "\sysutil\util") Then obFS.createFolder sSysDrive & "\sysutil\util"
	If Not obFS.folderExists(sSysDrive & "\sysutil\logs") Then obFS.createFolder sSysDrive & "\sysutil\logs"

If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Subroutine sbBuildSysutil", Err.Source, Err.number, Err.description, "")
	err.clear
End If
ON ERROR GOTO 0
End Sub

'----------
Sub sbMapNetworkDrives(sDomCfg, sLocCfg)
'----------
'This subroutine is responsible for mapping network drives. The network drive properties can be found in the netlogon\domain\config.xml
'and netlogon\locations\"location"\config.xml files. The MS XML parser is used to enumerate the xml file and map drives according to the
'documented properties.

on error resume next
	Dim obCnfg, obNetConns, obXml
	Dim arCfgs
	Dim sDrv
	Dim i
	Dim bNoGlobalMaps
	Dim x
		
	Set obNetConns = GetObject("script:" & sDomainWscDir & "\mapNetworkResources.wsc")
	Set obXml = CreateObject("Microsoft.XMLDOM")
	
	If fnIsArgSet(WScript.Arguments, "/noglobalmaps") Then bNoGlobalMaps = True
	
	Select Case bNoGlobalMaps
		Case True : arCfgs = array(sLocCfg)
		Case Else : arCfgs = array(sDomCfg, sLocCfg)
	End Select

	If bLogging Then
    For each x in arCfgs
    		WScript.Echo vbTab & "::: " &vbTab & x
    Next
	End If


	For i = 0 to ubound(arCfgs)
		obXml.async = False
		obXml.load(arCfgs(i))
		obXml.setProperty "SelectionLanguage", "XPath"
		Set obCnfg = obXml.documentElement.selectSingleNode("//configuration/mappings/networkDrives").childNodes
		
		For each sDrv in obCnfg
			If lcase(sDrv.nodename) = "drive" Then
				Select Case lcase(sDrv.getAttribute("action"))
					Case "mapnew"
						obNetConns.mapNewDrive sDrv.getAttribute("label"), sDrv.getAttribute("location")
						If bLogging Then
							WScript.Echo vbTab & "Mapping drive " & sDrv.getAttribute("label") & " to " & sDrv.getAttribute("location") & " - " & Time
						End If
					Case "replace"
						obNetConns.replaceExistingDrive sDrv.getAttribute("label"), sDrv.getAttribute("oldLocation"), sDrv.getAttribute("newLocation")
						If bLogging Then
							WScript.Echo vbTab & "Replacing existing drive " & sDrv.getAttribute("label") & " with new path " & sDrv.getAttribute("location") & " - " & Time
						End If
				End Select
			End If
		Next
	Next
	
If err.number <> 0 Then
	If bLogging Then
		WScript.Echo vbTab & "ERROR ENCOUNTERED when mapping one of the previous drives!"
	End If
	Call sbWriteEvent(WScript.ScriptName & ":Subroutine: sbMapNetworkDrives", Err.Source, Err.number, Err.description, "")
	err.clear
End If
ON ERROR GOTO 0
End Sub

Sub sbProcessGrpUtls(sDomDir, sLocDir)
'----------
'Subroutine that executes code found in the netlogon\domain\grp and netlogon\locations\"site-location\grp folders. All user group membership
'is enumerated (including nested groups). If a script is found in either directory that matches an associated group name it is executed. All script
'execution is handled as a separate process and the logon script DOES NOT wait for group utility execution to complete before continuing.

on error resume next
	Dim arGrpDirs
	Dim coGrpBasedScripts
	Dim sGrpBasedFile, sGrpNameCheck
	Dim i, j, x
	Dim bFilesFound
	Dim bIsMemberOf
	Dim arTemp
	Dim sGroupName
	Dim sScriptExtension
	Dim sGroupDN
	Dim obGroup

	arGrpDirs = array(sDomDir, sLocDir)
	bFilesFound = False

	For i = 0 To ubound(arGrpDirs)
		If obFS.GetFolder(arGrpDirs(i)).Files.Count > 0 Then
			bFilesFound = True
		End If
	Next
	
	If bFilesFound = True Then
		If bLogging Then
			WScript.Echo vbTab & "One or more files found to process - " & Time
		End If
		For i = 0 To ubound(arGrpDirs)
			If bLogging Then
				WScript.Echo vbTab & obFS.GetFolder(arGrpDirs(i)).Files.Count & " files found in " & arGrpDirs(i) & " - " & Time
			End If
			
			If obFS.GetFolder(arGrpDirs(i)).Files.Count > 0 Then
				
				Set coGrpBasedScripts = obFS.getFolder(arGrpDirs(i)).Files
				For Each sGrpBasedFile In coGrpBasedScripts
					bIsMemberOf = False
					If bLogging Then
						WScript.Echo vbTab & "Processing file: " & sGrpBasedFile.name & " - " & Time
					End If
					arTemp = Split(sGrpBasedFile.name, ".")
					sGroupName = ""
					sScriptExtension = arTemp(UBound(arTemp))
					For x = 0 To UBound(arTemp)-1
						sGroupName = sGroupName & "." & arTemp(x)
					Next
					sGroupName = Right(sGroupName, Len(sGroupName)-1)
					arTemp = ""

					If bLogging Then
						WScript.Echo vbTab & vbTab & "Searching AD for group: " & sGroupName & " - " & Time
					End If
					sGroupDN = fnSearchForGroupDN(sGroupName)
					If sGroupDN <> "" Then
						If bLogging Then
							WScript.Echo vbTab & vbTab & "Group found" & " - " & Time
							WScript.Echo vbTab & vbTab & "Group dn: " & sGroupDN
						End If
						Set obGroup = GetObject("LDAP://" & sGroupDN)
						If obGroup.IsMember("LDAP://" & sUsrDn) Then
							bIsMemberOf = True
						End If
					Else
						If bLogging Then
							WScript.Echo vbTab & vbTab & "Group NOT found!" & " - " & Time
						End If
					End If
				
					If bIsMemberOf = True Then

						Select Case sScriptExtension
							Case "wsf", "vbs", "vbe", "js", "jse"
								If bLogging Then
									WScript.Echo vbTab & vbTab & "Executing: " & sGrpBasedFile.Name & " - " & Time
								End If
								obShell.Run "cscript " & arGrpDirs(i) & "\" & sGrpBasedFile.Name, 0, False
							Case "cmd", "bat", "ps1", "exe"
								If bLogging Then
									WScript.Echo vbTab & vbTab & "Executing: " & sGrpBasedFile.Name & " - " & Time
								End If
								obShell.Run arGrpDirs(i) & "\" & sGrpBasedFile.Name, 0, False
							Case "reg"
								If bLogging Then
									WScript.Echo vbTab & vbTab & "Executing: " & sGrpBasedFile.Name & " - " & Time
								End If
								obShell.run "Regedit.exe /s " & arGrpDirs(i) & "\" & sGrpBasedFile.Name, 0, False
						End Select
					End If
					sGroupName = ""
					arTemp = ""
					sScriptExtension = ""
					sGroupDN = ""
					Set obGroup = Nothing
				Next
			End If
		Next
	End If
		 
If err.number <> 0 Then
	Call sbWriteEvent(WScript.ScriptName & ":Subroutine sbProcessGrpUtls", Err.Source, Err.number, Err.description, "")
 	err.clear
End If
ON ERROR GOTO 0
End Sub

Function fnSearchForGroupDN(sGroupSamAcctName)
'Returns the DN of a group given the group's sAMAccountName.

'on error resume next
Dim obAD : Set obAD = GetObject("script:" & sDomainWscDir & "\queryAD.wsc")
Dim sLdapRoot : sLdapRoot = obDSE.Get("defaultNamingContext")
Dim sSQL, adRs, sDN

'Query Active Directory to get DN
'sSQL = "SELECT distinguishedName FROM 'LDAP://" & sLdapRoot & "' WHERE objectCategory='group' AND sAMAccountName='" & sGroupSamAcctName &"'"
sSQL = "SELECT distinguishedName FROM 'GC://companyname.com" & "' WHERE objectCategory='group' AND sAMAccountName='" & sGroupSamAcctName &"'"

Set adRs = obAD.doSQLquery(sSQL)
sDN = adRs("distinguishedName")

Set adRs = Nothing
Set obAD = Nothing
fnSearchForGroupDN = sDN
On error Goto 0

End Function

'----------
Sub sbProcessUsrUtls
'----------
'This subroutine is responsible for parsing code specific to a user. Snippets of code are placed in the \inc\usr directory and named
'to match a valid user name. If a user name matches the name of the code snippet the code is executed.

on error resume next
	Dim arFileParts
	Dim i
	
	for i = 0 to ubound(arScriptExtensions)
		If obFS.FileExists(sDomainUsrDir & "\" & sUsrName & "." & arScriptExtensions(i)) Then
			Select Case arScriptExtensions(i)
				Case "wsf", "vbs", "vbe", "js", "jse"
					obShell.Run "cscript " & sDomainUsrDir & "\" & sUsrName & "." & arScriptExtensions(i), 0, False
				Case "cmd", "bat", "ps1", "exe"
					obShell.Run sDomainUsrDir & "\" & sUsrName & "." & arScriptExtensions(i),  0, False
				Case "reg"
					obShell.run "Regedit.exe /s " & sDomainUsrDir & "\" & sUsrName & "." & arScriptExtensions(i), 0, False
			End Select
		End If
	Next
If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Subroutine sbProcessUsrUtls", Err.Source, Err.number, Err.description, "")
	err.clear
End If
ON ERROR GOTO 0
End Sub

'----------
Sub sbProcessUtls(sDomDir, sLocDir)
'----------
'Subroutine that executes code found in the netlogon\domain\utl And netlogon\locations\"site-location\utl folders. All script execution
'is handled as a separate process and the logon script DOES NOT wait for group utility execution to complete before continuing.

on error resume next
	Dim arUtilDirs, arFileParts
	Dim sExtension, increment, sUtil, sUtilDir, sUtils
	Dim i

	arUtilDirs = array(sDomDir, sLocDir)
	For i = 0 to ubound(arUtilDirs)
		Set sUtils = obFS.getFolder(arUtilDirs(i)).Files
		If sUtils.Count <> 0 Then
			For Each sUtil in sUtils
	        	If bLogging Then
	          	WScript.Echo vbTab & "Processing file: " & sUtil.Name & " - " & Time
	        	End If
				arFileParts = Split(sUtil.Name, ".")
				sExtension =  lcase(arFileParts(Ubound(arFileParts)))
				Select Case sExtension
					Case "wsf", "vbs", "vbe", "js", "jse"
			            If bLogging Then
			              WScript.Echo vbTab & vbTab & "Running command: " & "cscript " & sUtil.path & " - " & Time
			            End If
						obShell.Run "cscript " & sUtil.path, 0, False
					Case "cmd", "bat", "ps1", "exe"
						obShell.run sUtil.path, 0, False
					Case "reg"
						obShell.run "Regedit.exe /s " & sUtil.path, 0, False
				End Select
			Next
		End If
	Next
	
If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Subroutine sbProcessUtls", Err.Source, Err.number, Err.description, "")
	err.clear
End If
ON ERROR GOTO 0
End Sub

'----------
Sub sbSearchGrps(obObj)
'----------
'This is a recursive subroutine that is responsible For collection group membership an object. All group membership
'is collected including indirect or "nested" group membership. dtGrpName is a vbscript dictionary object that is instantiated
'in the script execution portion of the script and is used in the sbProcessGrpUtls subroutine.

on error resume next
	Dim arGrps
	Dim obGrp
	Dim i
	
	If bLogging Then
		WScript.Echo vbTab & vbTab & vbTab & "Starting Enumerate group membership" & " - " & Time
	End If

	dtGrpName.CompareMode = vbTextCompare
	arGrps = obObj.memberOf
	
	If (IsEmpty(arGrps) = True) Then
		'Do Nothing
		Exit Sub
	End If
	
	If (TypeName(arGrps) = "String") Then
		Set obGrp = GetObject("LDAP://" & arGrps)
		If (dtGrpName.Exists(obGrp.samAccountName) = False) Then
			dtGrpName.Add obGrp.samAccountName, True
			Call sbSearchGrps(obGrp)
		End If
		Set obGrp = Nothing
		Exit Sub
	End If
	For i = 0 To UBound(arGrps)
		Set obGrp = GetObject("LDAP://" & arGrps(i))
		If (dtGrpName.Exists(obGrp.samAccountName) = False) Then
			dtGrpName.Add obGrp.samAccountName, True
			Call sbSearchGrps(obGrp)
		End If
	Next
	Set obGrp = Nothing

	If bLogging Then
		WScript.Echo vbTab & vbTab & vbTab & "COMPLETE Enumerate group membership" & " - " & Time
	End If

If err.number <> 0 Then 
 	Call sbWriteEvent(WScript.ScriptName & ":Subroutine sbSearchGrps", Err.Source, Err.number, Err.description, "")
 	err.clear
End If
ON ERROR GOTO 0
End Sub

'----------
Sub sbWriteEvent(sSubFuncName, sErrSource, sErrNumber, sErrDescription, sErrComment)
'----------
on error resume next
	Dim obEventLog
 	Set obEventLog = GetObject("script:" & sDomainWscDir & "\writeEventLogError.wsc")
 	obEventLog.writeEvent sSubFuncName, sErrSource, sErrNumber, sErrDescription, sErrComment
	Set obEventLog = Nothing
on error GOTO 0
End Sub

'----------
Function fnQueryADsPath(sObType)
'----------
'Returns the ADsPath of the current user or computer object using an ADSI query.

on error resume next
Dim obAD : Set obAD = GetObject("script:" & sDomainWscDir & "\queryAD.wsc")
Dim sLdapRoot : sLdapRoot = obDSE.Get("defaultNamingContext")
Dim sSQL, adRs, sADsPath

'Query Active Directory to get ADsPath
Select Case LCase(sObType)
	Case "user" : sSQL = "SELECT ADsPath FROM 'LDAP://" & sLdapRoot & "' WHERE objectCategory='person' AND objectClass='user' AND sAMAccountName='" & sUsrName &"'"
	Case "computer" : sSQL = "SELECT ADsPath FROM 'LDAP://" & sLdapRoot & "' WHERE objectCategory='computer' and sAMAccountName='" & sCmpName & "$'"
	Case Else : Exit Function
End Select

Set adRs = obAD.doSQLquery(sSQL)
sADsPath = adRs("ADsPath")

Set adRs = Nothing
Set obAD = Nothing
fnQueryADsPath = sADsPath
On error Goto 0

End Function

'----------
Function fnGetADsPath(sObType)
'----------
'Returns the ADsPath of the current user or computer object. Uses 'ADSystemInfo' object to do a direct bind.

on error resume next
Dim obAD : Set obAD = CreateObject("ADSystemInfo")
Dim sADsPath
Select Case LCase(sObType)
	Case "computer" : sADsPath = "LDAP://" & Replace(obAD.ComputerName, "/", "\/")
	Case "user" : sADsPath = "LDAP://" & Replace(obAD.UserName, "/", "\/")
	Case Else : Exit Function
End Select
Set obAD = Nothing

If sADsPath <> "" Then
	fnGetADsPath = sADsPath
Else
	fnGetADsPath = fnQueryADsPath(sObType)
End If
on error GoTo 0

End Function

'----------
Function fnGetConfigLocation()
'----------
'Function that determines the location of the config.xml that should be processed during script execution.

on error resume next
	Dim obArgs, obFldr, obFldrs
	Dim arArgs, arCmpLoc, arUsrLoc
	Dim bFoundFolder
	Dim i
	Dim obFolderDictionary
	
	If fnIsArgSet(WScript.Arguments, "/location") Then
		fnGetConfigLocation = WScript.Arguments.Named("location")
		If bLogging Then
      		WScript.Echo vbTab & "Named location argument found: location='" & WScript.Arguments.Named("location") & "' - " & Time
    	End If
	  	Exit Function
	Else
		sUsrLocation = Replace(sUsrLocation, " ", "")
		If obFS.folderExists(sScriptDir & "locations\" & sUsrLocation) Then
	    	If bLogging Then
      			WScript.Echo vbTab & "Location folder found: location='" & sUsrLocation & "' - " & Time
    		End If
    		fnGetConfigLocation = sUsrLocation
    	Else
	    	If bLogging Then
      			WScript.Echo vbTab & "Location folder not found, using default: '" & "_default" & "' - " & Time
    		End If
    		fnGetConfigLocation = "_default"
    	End If
   		exit function
  	End If

If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Function fnGetConfigLocation()", Err.Source, Err.number, Err.description, "")
	err.clear
End If
on error GOTO 0
End Function

'----------
Function fnGetNormalizedUsrName(sUserName)
'----------
on error resume next
	If left(lcase(sUserName), 4) = "xxxx" Or left(lcase(sUserName), 4) = "zzzz" Then
		fnGetNormalizedUsrName = trim(lcase(Mid(sUserName, 5, Len(sUserName))))
	Else
		fnGetNormalizedUsrName = trim(lcase(sUserName))
	End If
If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Function fnGetNormalizedUsrName()", Err.Source, Err.number, Err.description, "")
	err.clear
End If
on error GOTO 0
End Function

'----------
Function fnIsDesktop()
'----------
on error resume next
	If ( instr(lcase(sCmpAdPath), "server") = 0 ) AND ( instr(lcase(sCmpAdPath), "specialaccounts") = 0 ) Then
		fnIsDesktop = True
	Else
		fnIsDesktop = False
	End If
	
If err.number <> 0 Then 
	Call sbWriteEvent(WScript.ScriptName & ":Function fnIsDesktop()", Err.Source, Err.number, Err.description, "")
	err.clear
End If
on error GOTO 0
End Function

'--------------------
Function fnIsArgSet(arArgs, sArg)
'--------------------

on error resume next

Dim i, sArgName
For i = 0 To arArgs.Count - 1
       If InStr(arArgs(i), ":") > 0 Then
              sArgName = Split(arArgs(i), ":")(0)
       Else
              sArgName = arArgs(i)
       End If
       If LCase(sArgName) = LCase(sArg) Then
              fnIsArgSet = True
              Exit For
       Else
              fnIsArgSet = False
       End If
       sArgName = ""
Next

On Error GoTo 0

End Function

'--------------------
Function fnIsRemoteLogon(sProtocol)
'--------------------
'Returns true/false based on whether the specified Remote Login protocol is being used (i.e. ICA/RDP)

on error resume next

Dim bIsRemoteLogon : bIsRemoteLogon = False
Dim sSessionName : sSessionName = obShell.ExpandEnvironmentStrings("%SESSIONNAME%")
If sSessionName <> "" Then
     Dim sSessionProtocol : sSessionProtocol = Left(sSessionName, 3)
     If UCase(sSessionProtocol) = UCase(sProtocol) Then bIsRemoteLogon = True
End If
fnIsRemoteLogon = bIsRemoteLogon

On Error GoTo 0

End Function

'--------------------
Sub sbHideDriveLetters(arDriveLetters,bDeleteExisting)
'--------------------

on error resume next

Dim arDriveDecValues, sDriveLetter, iDriveDecValue

Dim obRegEx  : Set obRegEx = New RegExp
obRegEx.IgnoreCase = True
obRegEx.Global = False
obRegEx.Pattern = "^[A-Za-z]{1}:?$" 'Match only a single letter of the alphabet, regardless of case.

arDriveDecValues = Array(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432)

Dim sRegVal : sRegVal = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDrives"
Dim iNoDrives : iNoDrives = obShell.RegRead(sRegVal)
If ((iNoDrives > 0) = False) Or bDeleteExisting Then
	iNoDrives = 0
	obShell.RegWrite sRegVal, 0, "REG_DWORD"
End If

For Each sDriveLetter In arDriveLetters
	If obRegEx.Test(sDriveLetter) Then
		'Get decimal value of drive letter
		iDriveDecValue = arDriveDecValues(Asc(Left(UCase(sDriveLetter),1))-65)
		If Not ((iNoDrives And iDriveDecValue) <> 0) Then
			'Drive is not currently hidden
			iNoDrives = iNoDrives + iDriveDecValue
			obShell.RegWrite sRegVal, iNoDrives, "REG_DWORD"
		End If
	End If
Next

On Error GoTo 0

End Sub