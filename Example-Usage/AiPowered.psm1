<#
    AI POWERED

    This module implements AI-powered functionalities for PowerShell.
#>
$ErrorActionPreference = "Stop"

# Load necessary assemblies and modules
Add-Type -AssemblyName System.Web

Push-Location $PSScriptRoot

Get-ChildItem -Filter "*.ps1" -Recurse | 
    ForEach-Object {
        . ($_.Fullname)
    }

Pop-Location

