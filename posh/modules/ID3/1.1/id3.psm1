function Get-Id3Tag
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Path
    )

    $media = [TagLib.File]::Create( (Resolve-Path $Path) )
    $media.Tag
    $media = $null
}

function Set-Id3Tag
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        $Path,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $Tags
    )

    $media = [TagLib.File]::Create( (Resolve-Path $Path) )
    foreach($key in $Tags.Keys)
    {
        $media.Tag.$key = $Tags[$key]
    }

    if($PSCmdlet.ShouldProcess( $($media.Tag | Out-String) ))
    {
        $media.Save()
    }

    $media = $null
}