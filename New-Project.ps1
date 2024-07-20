<#
    Creates a new dotnet project with my preferred structure, commits it, pushes to remote, and removes itself
#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

function New-ClassLib {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Namespace,
        [Parameter(Mandatory=$true)]
        [string]$ToProject,
        [switch]$ForUnitTesting
    )

    Process {
        mkdir $Namespace
        Push-Location $Namespace

        dotnet new classlib

        if ($ForUnitTesting) {
            dotnet add package Microsoft.NET.Test.Sdk
            dotnet add package NUnit
            dotnet add package NUnit3TestAdapter
        }

        Pop-Location

        dotnet sln "./$($ToProject).sln" add "./$($Namespace)/"
    }
}

# Store the script path for later removal
$scriptPath = $MyInvocation.MyCommand.Path

# Change to the Source directory
$sourceDir = Join-Path $PSScriptRoot "Source"
if (-not (Test-Path $sourceDir)) {
    mkdir $sourceDir
}
Set-Location $sourceDir

# Create project directory
mkdir $ProjectName
Set-Location $ProjectName

# Remove .gitkeep file if it exists
$gitkeepFile = Join-Path $PSScriptRoot "Source\.gitkeep"
if (Test-Path $gitkeepFile) {
    Remove-Item $gitkeepFile -Force
}

dotnet new sln
dotnet new gitignore

New-ClassLib ($ProjectName + ".BL") -ToProject $ProjectName
New-ClassLib ($ProjectName + ".BL.Tests") -ToProject $ProjectName -ForUnitTesting

# Return to the root directory
Set-Location $PSScriptRoot

# Git operations
git add .
git commit -m "Initialize $ProjectName project"
git push

# Remove the script
Remove-Item $scriptPath -Force

Write-Host "Project $ProjectName has been created, committed, and pushed. This script will now be deleted."