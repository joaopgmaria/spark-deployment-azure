function ConvertTo-Base64
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$text
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    return [Convert]::ToBase64String($bytes)
}

function Install-ModuleIfNeeded
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )

    if (-not (Get-Module -ListAvailable -Name $Name))
{
    Write-Host "Installing Module '$Name'..."
    Install-Module $Name -AllowClobber -SkipPublisherCheck -Force
}
}

