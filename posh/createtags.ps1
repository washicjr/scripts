$tagFile = "E:\.tmp\music\.meta\tags\tags.txt"

$newStr = Get-Clipboard -Raw
$newStr = $newStr -replace '\r\nfeat: ', '/'                 #Normalize Artists
$newStr = $newStr -replace ' / ', '/'                        #Normalize Separator'
$newStr = $newStr -replace '\d\d:\d\d', ''                   #Delete Length Info
$newStr = $newStr -replace 'Rdio', ''                        #Delete Rdio String
$newStr = $newStr -replace 'Spotify', ''                     #Delete Spotify String
$newStr = $newStr -replace 'Mog', ''                         #Delete Mog String
$newStr = $newStr -replace 'Amazon',''                       #Delete Amazon String
$newStr = $newStr -replace 'Songreview', ''                  #Delete Songreview String
$newStr = $newStr -replace 'Song Review',''                  #Delete Song Review String
$newStr = $newStr -replace '\s*\z', ''                       #Delete Extra White Space
$newStr = $newStr -replace '\t*', ''                         #Delete Extra White Space
$newStr = $newStr -replace '\r\n', '|'                       #Add Delimiters
$newStr = $newStr -replace '\|\|', "`r`n"                    #Create Unique Records
$newStr = $newStr -replace 'Track Listing \- Disc \d\|Title\/ComposerPerformerTimeStream\|'

Set-Content -path $tagfile -Value $newStr -Force
notepad $tagFile
