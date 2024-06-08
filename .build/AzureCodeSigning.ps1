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
    $AzureKeyVaultAppSecret = (property AzureKeyVaultAppSecret ''),

    [Parameter()]
    [string]
    $ReleaseBranch = (property ReleaseBranch 'main'),

    [Parameter()]
    $BuildInfo = (property BuildInfo @{ }),

    [Parameter()]
    $MainGitBranch = (property MainGitBranch 'main')
)

task Sign -if ($AzureKeyVaultAppSecret) {

    . Set-SamplerTaskVariable

    $files = foreach ($filter in $BuildInfo.CodeSigning.FileSelection.Filters)
    {
        dir -Path $BuiltModuleBase -Filter $filter -Recurse
    }

    $files += foreach ($path in $BuildInfo.CodeSigning.FileSelection.FilePaths)
    {
        $path = Join-Path -Path $BuiltModuleBase -ChildPath $path
        Get-Item -Path $path
    }

    foreach ($file in $files)
    {
        Write-Build DarkGray "Signing file '$($file.FullName)'"
        AzureSignTool.exe sign -kvu $BuildInfo.CodeSigning.AzureKeyVault.Url -kvi $BuildInfo.CodeSigning.AzureKeyVault.ApplicationId -kvs $AzureKeyVaultAppSecret -kvc $BuildInfo.CodeSigning.AzureKeyVault.CertificateName -v $file.FullName
    }
}
