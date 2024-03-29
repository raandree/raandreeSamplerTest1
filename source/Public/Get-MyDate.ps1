function Get-MyDate
{
    <#
      .SYNOPSIS
      Sample Function to return input string.

      .DESCRIPTION
      This function is only a sample Advanced function that returns the Data given via parameter Data.

      .EXAMPLE
      Get-Something -Data 'Get me this text'


      .PARAMETER Data
      The Data parameter is the data that will be returned without transformation.

    #>
    [cmdletBinding()]
    [OutputType([string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Write-Host is needed.')]
    param
    ()

    $d = Get-Date
    "The date is $($d.ToString())"
}
