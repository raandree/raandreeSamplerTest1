task GitVersion -if (Get-Command -Name dotnet-gitversion.exe, gitversion.exe -ErrorAction SilentlyContinue) {

    $command = if (Get-Command -Name gitversion.exe -ErrorAction SilentlyContinue)
    {
        Write-Host 'Using gitversion.exe...'
        'gitversion.exe'
    }
    elseif (Get-Command -Name dotnet-gitversion -ErrorAction SilentlyContinue)
    {
        Write-Host 'Using dotnet-gitversion...'
        'dotnet-gitversion'
    }
    else
    {
        Write-Error 'Neither gitversion.exe nor dotnet-gitversion is available.'
        return
    }

    #dotnetgitversioninstall: Sepertate install task only on Az Agents without GitVersion not installed

    if (Get-Command -Name dotnet-gitversion -ErrorAction SilentlyContinue)
    {
        Write-Host 'dotnet-gitversion is already installed.'
    }
    else
    {
        Write-Host 'Installing dotnet-gitversion...'
        dotnet tool install --global GitVersion.Tool
        Write-Host 'done.'
    }

    #Write-Host 'Installing GitVersion.Tool...' -NoNewline
    #dotnet tool install --global GitVersion.Tool
    #Write-Host 'done.'

    #either dotnet-gitversion or gitversion
    $gitVersionObject = & $command
    Write-Host -------------- GitVersion Outout --------------
    $gitVersionObject | Write-Host
    Write-Host -----------------------------------------------

    $gitVersionObject = $gitVersionObject | ConvertFrom-Json
    $longestKeyLength = ($gitVersionObject | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Sort-Object { $_.Length } | Select-Object -Last 1).Length
    $gitVersionObject.PSObject.Properties.ForEach{
        Write-Host -Object ("Setting Task Variable {0,-$longestKeyLength} with value '{1}'." -f $_.Name, $_.Value)
        Write-Host -Object "##vso[task.setvariable variable=$($_.Name);]$($_.Value)"
    }

    #Check the gitversion modes (CD) / how gitversion calculates the prerelease version
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

    Write-Host -Object "Writing version string '$versionString' to build variable 'NuGetVersionV2'."
    #Write-Host -Object "##vso[task.setvariable variable=NuGetVersionV2;]$($versionString)"
    Write-Host -Object "##vso[task.setvariable variable=ModuleVersion;]$($versionString)"
    $env:ModuleVersion = $versionString
    $global:ModuleVersion = $versionString
    [System.Environment]::SetEnvironmentVariable('ModuleVersion', $versionString, 'Process')

    Write-Host -Object "Updating build number to '$versionString'."
    Write-Host -Object "##vso[build.updatebuildnumber]$($versionString)"
}

#$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
#ModuleVersion: $(NuGetVersionV2)
