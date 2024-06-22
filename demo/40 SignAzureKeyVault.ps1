
$tenantId = '195822f4-c716-4ff8-ba91-90f1a2195700'
$keyVaultName = 'kv1111'
$appId = 'bad81edd-bbbe-48c7-a355-bd146e4f7197'
$secret = Read-Host -Prompt 'Enter the secret for the application'
$secureSecret = $secret | ConvertTo-SecureString -AsPlainText -Force

# Don't do this
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name SignTest -AsPlainText
$secretBytes = [System.Convert]::FromBase64String($secret)
$pfxCertObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $secretBytes, '', 'Exportable'
[System.IO.File]::WriteAllBytes('.\temp.pfx', $secretBytes)

# Let Azure Key Vault handle the signing process
$credential = New-Object System.Management.Automation.PSCredential ($appId, $secureSecret)
Connect-AzAccount -ServicePrincipal -Tenant $tenantId -Credential $credential
Get-AzKeyVaultCertificate -VaultName $keyVaultName -Name SignTest
Get-AzKeyVaultSecret -VaultName $keyVaultName -Name SignTest -AsPlainText #this no longer works

dotnet tool install --global AzureSignTool --version 5.0.0

'Get-Date' | Out-File -FilePath .\TestAzureKeyVaylt.ps1
$scriptFile = Get-Item -Path .\TestAzureKeyVaylt.ps1
AzureSignTool.exe sign -kvu https://$keyVaultName.vault.azure.net -kvi $appId -kvs $secret -kvc SignTest -tr http://timestamp.digicert.com -v $scriptFile.FullName

Get-AuthenticodeSignature -FilePath $scriptFile.FullName
