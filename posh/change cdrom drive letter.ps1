# Letter you want to assign
$CdRomDriveLetter = "A:"

# Obtain current assigned letter
$CdRomCurrentLetter = (Get-WmiObject -Class Win32_CDROMDrive).Drive

# Mount and then umount it, in order to obtain its volume name which is needed later
$CdRomVolumeName = mountvol $CdRomCurrentLetter /l
$CdRomVolumeName = $CdRomVolumeName.Trim()
mountvol $CdRomCurrentLetter /d

# Assign new letter
mountvol $CdRomDriveLetter $CdRomVolumeName