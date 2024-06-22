param
(
    [Parameter()]
    [System.String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $VersionedOutputDirectory = (property VersionedOutputDirectory $true),

    [Parameter()]
    [System.String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    [string]
    $AzureKeyVaultAppSecretPrerelease = (property AzureKeyVaultAppSecretPrerelease ''),

    [Parameter()]
    [string]
    $AzureKeyVaultAppSecretRelease = (property AzureKeyVaultAppSecretRelease ''),

    [Parameter()]
    [string]
    $ReleaseBranch = (property ReleaseBranch 'main'),

    [Parameter()]
    $BuildInfo = (property BuildInfo @{ }),

    [Parameter()]
    $MainGitBranch = (property MainGitBranch 'main')
)

task Sign {

    . Set-SamplerTaskVariable

    if ($moduleVersionObject.PreReleaseString -and -not $BuildInfo.CodeSigning.AzureKeyVault.Prerelease)
    {
        Write-Build Yellow "Skipping code signing for pre-release version '$($moduleVersionObject.ModuleVersion)' as no key vault for pre-release is configured in the 'build.yml' file."
        return
    }
    elseif ($moduleVersionObject.PreReleaseString -and [string]::IsNullOrEmpty($AzureKeyVaultAppSecretPrerelease))
    {
        Write-Error "No key vault secret for pre-release is configured in the pipeline variables. Please store the secret in the pipeline variable named 'AzureKeyVaultAppSecretPrerelease'."
    }

    if (-not $moduleVersionObject.PreReleaseString -and -not $BuildInfo.CodeSigning.AzureKeyVault.Release)
    {
        Write-Error "No key vault for release is configured in the 'build.yml' file."
    }
    elseif (-not $moduleVersionObject.PreReleaseString -and [string]::IsNullOrEmpty($AzureKeyVaultAppSecretRelease))
    {
        Write-Error "No key vault secret for release is configured in the pipeline variables. Please store the secret in the pipeline variable named 'AzureKeyVaultAppSecretRelease'."
    }

    $files = foreach ($filter in $BuildInfo.CodeSigning.FileSelection.Filters)
    {
        dir -Path $BuiltModuleBase -Filter $filter -Recurse
    }

    $files += foreach ($path in $BuildInfo.CodeSigning.FileSelection.FilePaths)
    {
        $path = Join-Path -Path $BuiltModuleBase -ChildPath $path
        Get-Item -Path $path
    }

    $key = if ($moduleVersionObject.PreReleaseString)
    {
        'Prerelease'
    }
    else
    {
        'Release'
    }

    foreach ($file in $files)
    {
        Write-Build DarkGray "Signing file '$($file.FullName)'"
        $param =
        'sign',
        '-kvt', $BuildInfo.CodeSigning.AzureKeyVault."$key".TenantId,
        '-kvu', $BuildInfo.CodeSigning.AzureKeyVault."$key".Url,
        '-kvi', $BuildInfo.CodeSigning.AzureKeyVault."$key".ApplicationId,
        '-kvs', (Get-Variable -Name "AzureKeyVaultAppSecret$key" -ValueOnly),
        '-kvc', $BuildInfo.CodeSigning.AzureKeyVault."$key".CertificateName,
        '-tr', $BuildInfo.CodeSigning.AzureKeyVault."$key".TimeStampServerUrl,
        '-v',
        $file.FullName

        AzureSignTool.exe @param

        if ($LASTEXITCODE -ne 0)
        {
            Write-Error "Failed to sign file '$($file.FullName)'. The exit code was '$LASTEXITCODE'. Please see the log above for more details."
        }
        else
        {
            Write-Build Green "File '$($file.FullName)' signed successfully."
        }
    }
}
