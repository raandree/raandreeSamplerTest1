#Install-Module -Name Az.Accounts
#Install-Module -Name Az.KeyVault

$tenantId = '195822f4-c716-4ff8-ba91-90f1a2195700'
$subscriptionId = '329752f3-d90c-4ae8-8c85-46a678203df4'
$keyVaultName = 'kv1111'

Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

$certificatePassword = ConvertTo-SecureString -String x -AsPlainText -Force

Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name SignTest -FilePath .\SigningCertTest.pfx -Password $certificatePassword
Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name SignRelease -FilePath .\SigningCertRelease.pfx -Password $certificatePassword
