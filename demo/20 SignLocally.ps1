$cert = Get-ChildItem -Path Cert:\LocalMachine\TrustedPublisher -CodeSigningCert | Where-Object Subject -eq CN=CodeSigningTest

$cert.HasPrivateKey

'Get-Date' | Out-File -FilePath .\Test.ps1
$result = Set-AuthenticodeSignature -FilePath .\Test.ps1 -Certificate $cert -Verbose -HashAlgorithm SHA256
$result

'Get-Date' | Out-File -FilePath .\TestWithTimeStamp.ps1
$result = Set-AuthenticodeSignature -FilePath .\TestWithTimeStamp.ps1 -Certificate $cert -Verbose -HashAlgorithm SHA256 -TimestampServer http://timestamp.digicert.com
$result

Get-AuthenticodeSignature -FilePath .\Test.ps1 | fl *

Get-AuthenticodeSignature -FilePath .\TestWithTimeStamp.ps1 | fl *
