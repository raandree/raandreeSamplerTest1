# Create Self signed root certificate
$param = @{
    Type              = 'Custom'
    KeySpec           = 'Signature'
    Subject           = 'CN=ContosoRoot'
    KeyExportPolicy   = 'Exportable'
    HashAlgorithm     = 'sha256'
    KeyLength         = 4096
    CertStoreLocation = 'Cert:\LocalMachine\My'
    KeyUsageProperty  = 'Sign'
    KeyUsage          = 'CertSign'
    NotAfter          = (Get-Date).AddYears(5)
}
$rootCert = New-SelfSignedCertificate @param

# Generate certificates from root (Code Signing Test)
$param = @{
    Type              = 'Custom'
    KeySpec           = 'Signature'
    Subject           = 'CN=CodeSigningTest'
    KeyExportPolicy   = 'Exportable'
    HashAlgorithm     = 'sha256'
    KeyLength         = 2048
    NotAfter          = (Get-Date).AddMonths(24)
    CertStoreLocation = 'Cert:\LocalMachine\My'
    Signer            = $rootCert
    TextExtension     = @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')
}
$signCertTest = New-SelfSignedCertificate @param

# Generate certificates from root (Code Signing Release)
$param = @{
    Type              = 'Custom'
    KeySpec           = 'Signature'
    Subject           = 'CN=CodeSigningRelease'
    KeyExportPolicy   = 'Exportable'
    HashAlgorithm     = 'sha256'
    KeyLength         = 2048
    NotAfter          = (Get-Date).AddMonths(24)
    CertStoreLocation = 'Cert:\LocalMachine\My'
    Signer            = $rootCert
    TextExtension     = @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')
}
$signCertRelease = New-SelfSignedCertificate @param

Move-Item -Path Cert:\LocalMachine\My\"$($signCertTest.Thumbprint)" -Destination Cert:\LocalMachine\TrustedPublisher
Move-Item -Path Cert:\LocalMachine\My\"$($signCertRelease.Thumbprint)" -Destination Cert:\LocalMachine\TrustedPublisher
Move-Item -Path Cert:\LocalMachine\My\"$($rootCert.Thumbprint)" -Destination Cert:\LocalMachine\Root

$bytes = $signCertTest.Export('PFX', 'x')
[System.IO.File]::WriteAllBytes("$PSScriptRoot\SigningCertTest.pfx", $bytes)

$bytes = $signCertRelease.Export('PFX', 'x')
[System.IO.File]::WriteAllBytes("$PSScriptRoot\SigningCertRelease.pfx", $bytes)
