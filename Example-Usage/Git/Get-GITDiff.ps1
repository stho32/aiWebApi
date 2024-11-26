function Get-GITDiff {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = "."
    )

    # Save current error action preference
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'

    try {
        Write-Verbose "Running git diff in '$Path'..."
        Push-Location $Path

        # Run git diff
        $gitDiff = & git diff 2>&1 | Out-String
        Write-Verbose "git diff returned: $gitDiff"
        
        # Get untracked files
        $untrackedFiles = @()
        $null = & git ls-files --others --exclude-standard 2>&1 | ForEach-Object { $untrackedFiles += $_ }
        Write-Verbose "Found $($untrackedFiles.Count) untracked files: $($untrackedFiles -join ', ')"

        if ([string]::IsNullOrWhiteSpace($gitDiff) -and $untrackedFiles.Count -eq 0) {
            Write-Host "No changes detected."
            return $null
        }

        $fullDiff = $gitDiff

        foreach ($file in $untrackedFiles) {
            Write-Verbose "Processing untracked file: $file"
            $fullDiff += "`n`nNew file: $file`n"
            $fullDiff += "------------------------`n"

            if (Test-Path $file -PathType Leaf) {
                $fileInfo = Get-Item $file

                $binaryExtensions = @('.pdf', '.bmp', '.png', '.jpg', '.jpeg', '.gif', '.exe', '.dll')
                $fileExtension = [System.IO.Path]::GetExtension($file).ToLower()

                if ($binaryExtensions -contains $fileExtension) {
                    Write-Verbose "Found binary file: $file"
                    $fullDiff += "[Binary file not displayed]"
                }
                else {
                    try {
                        $content = Get-Content $file -Raw -ErrorAction Stop
                        if ($content -match '[\x00-\x08\x0B\x0C\x0E-\x1F]') {
                            Write-Verbose "Found binary content in file: $file"
                            $fullDiff += "[Binary file not displayed]"
                        } else {
                            $fullDiff += $content
                        }
                    }
                    catch {
                        Write-Verbose "Error reading file: $file"
                        $fullDiff += "[Binary file not displayed]"
                    }
                }
            }
            else {
                Write-Verbose "File not found: $file"
                $fullDiff += "[File not found]"
            }

            $fullDiff += "`n------------------------`n"
        }

        return $fullDiff
    }
    catch {
        # Even if something goes wrong, try to return what we have
        if ($fullDiff) {
            Write-Warning "An error occurred, but returning available diff: $_"
            return $fullDiff
        }
        Write-Error "An error occurred while getting git diff: $_"
        return $null
    }
    finally {
        # Restore original error action preference
        $ErrorActionPreference = $oldErrorActionPreference
        Pop-Location
    }
}