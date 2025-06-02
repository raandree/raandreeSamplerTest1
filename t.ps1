$gitVersionObject = dotnet-gitversion
Write-Host -------------- GitVersion Outout --------------
$gitVersionObject | Write-Host
Write-Host -----------------------------------------------

$gitVersionObject = $gitVersionObject | ConvertFrom-Json
$longestKeyLength = ($gitVersionObject | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Sort-Object { $_.Length } | Select-Object -Last 1).Length
$gitVersionObject.PSObject.Properties.ForEach{
    Write-Host -Object ("Setting Task Variable {0,-$longestKeyLength} with value '{1}'." -f $_.Name, $_.Value)
    Write-Host -Object "##vso[task.setvariable variable=$($_.Name);]$($_.Value)"
}

$lastTag = git describe --tags --abbrev=0
$lastTag -match '^v(?<Version>(\d(\.)?){3})(-preview(?<PreviewReleaseNumber>\d{4}))?' | Out-Null
$lastVersion = $matches['Version']
$lastPreviewReleaseNumber = $matches['PreviewReleaseNumber']
$isLastTagPreRelease = [bool]$lastPreviewReleaseNumber
$isPreRelease = [bool]$gitVersionObject.PreReleaseLabel

$versionElements = $gitVersionObject.MajorMinorPatch

if ($isPreRelease)
{
    if ($gitVersionObject.BranchName -eq 'main')
    {
        $nextPreReleaseNumber = [int]$lastPreviewReleaseNumber + 1
        $paddedNextPreReleaseNumber = '{0:D4}' -f $nextPreReleaseNumber

        $versionElements += $gitVersionObject.PreReleaseLabelWithDash
        $versionElements += $paddedNextPreReleaseNumber
    }
    else
    {
        $versionElements += $gitVersionObject.PreReleaseLabelWithDash
        $versionElements += $gitVersionObject.PreReleaseNumber
    }
}


$versionString = -join $versionElements

Write-Host -Object "##vso[task.setvariable variable=NuGetVersionV2;]$($versionString)"
Write-Host -Object "##vso[build.updatebuildnumber]$($versionString)"
