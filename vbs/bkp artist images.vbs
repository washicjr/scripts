Set objFSO = CreateObject("Scripting.FileSystemObject")
objStartFolder = "E:\music\mp3"
Set objFolder = objFSO.GetFolder(objStartFolder)
Wscript.Echo objFolder.Path
Set colFiles = objFolder.Files

ShowSubfolders objFSO.GetFolder(objStartFolder)

Sub ShowSubFolders(Folder)
    For Each Subfolder in Folder.SubFolders
        Set objFolder = objFSO.GetFolder(Subfolder.Path)
        Set colFiles = objFolder.Files
        
        For Each objFile in colFiles
            if lcase(objFile.Name) = "artist.jpg" Then
		'Wscript.Echo Subfolder.Path
		'Wscript.Echo subfolder.Name
		'Wscript.Echo objFile.Name
		
		artistfile = Subfolder.Path & "\artist.jpg"
		folderfile = Subfolder.Path & "\folder.jpg"
		
		destFolder = "E:\.tmp\music\.meta\art\artist\" & Subfolder.Name
		
		If Not objFSO.FolderExists(destFolder) then 
			objFSO.CreateFolder destFolder
		End If
		
		objFSO.CopyFile artistfile, destFolder & "\artist.jpg"
		objFSO.CopyFile artistfile, destFolder & "\folder.jpg"
	    End If
        Next

        ShowSubFolders Subfolder
    Next
End Sub