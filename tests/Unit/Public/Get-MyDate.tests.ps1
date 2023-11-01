BeforeAll {
    $script:dscModuleName = 'raandreeSamplerTest1'

    Import-Module -Name $script:dscModuleName
}

AfterAll {
    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe Get-Something {
    Context 'When calling the function' {
        It 'Should return the current date' {
            $date = Get-MyDate
            $now = Get-Date

            $date.ToString() | Should -Be "The date is $($now.ToString())"
        }
    }

}
