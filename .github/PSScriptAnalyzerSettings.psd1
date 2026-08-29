@{
    # Rules excluded for BypassNRO:
    #
    # PSAvoidUsingWriteHost -- this is an interactive tool run from the OOBE
    #                          Shift+F10 console, where coloured status output
    #                          is the point. There is no pipeline to pollute.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost'
    )

    # The script targets Windows PowerShell 5.1, which is what Shift+F10
    # provides during OOBE.
    Rules = @{
        PSUseCompatibleCmdlets = @{
            compatibility = @(
                'desktop-5.1.14393.206-windows'
            )
        }
    }
}
