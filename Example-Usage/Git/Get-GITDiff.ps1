function Get-GITDiff {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = "."
    )

    try {
        Push-Location $Path

        # Run git diff and capture the output
        # Ignore the exit code as git diff might return non-zero exit codes that aren't errors
        $gitDiff = & git diff 2>&1
        
        # Get untracked files
        $untrackedFiles = & git ls-files --others --exclude-standard

        if ([string]::IsNullOrWhiteSpace($gitDiff) -and $untrackedFiles.Count -eq 0) {
            Write-Host "No changes detected."
            return $null
        }

        $fullDiff = $gitDiff

        foreach ($file in $untrackedFiles) {
            $fullDiff += "`n`nNew file: $file`n"
            $fullDiff += "------------------------`n"
            $fullDiff += Get-Content $file -Raw
            $fullDiff += "`n------------------------`n"
        }

        return $fullDiff
    }
    catch {
        Write-Error "An error occurred while getting git diff: $_"
        return $null
    }
    finally {
        Pop-Location
    }
}