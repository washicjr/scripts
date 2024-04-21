<#
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OLDER VERSION/LONG TERM SUPPORTED RELEASE OF POWERSHELL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#>
New-Item -Itemtype symboliclink -path c:\sysutil\bin\posh\core\older -target c:\sysutil\bin\posh\core\7.3

<#
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CURRENT/LATEST SUPPORTED RELEASE OF POWERSHELL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#>
New-Item -Itemtype symboliclink -path c:\sysutil\bin\posh\core\current -target c:\sysutil\bin\posh\core\7.4

<#
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PREVIEW  RELEASE OF POWERSHELL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#>
New-Item -Itemtype symboliclink -path c:\sysutil\bin\posh\core\preview -target c:\sysutil\bin\posh\core\7.5