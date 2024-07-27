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

            # Step 1: Check if the file exists and is not empty
            if (Test-Path $file -PathType Leaf) {
                $fileInfo = Get-Item $file

                # Step 2: Check file extension
                $binaryExtensions = @('.pdf', '.bmp', '.png', '.jpg', '.jpeg', '.gif', '.exe', '.dll')
                $fileExtension = [System.IO.Path]::GetExtension($file).ToLower()

                # Step 3: Check if it's a known binary format
                if ($binaryExtensions -contains $fileExtension) {
                    $fullDiff += "[Binary file not displayed]"
                }
                # Step 4: For other files, attempt to read content
                else {
                    try {
                        $content = Get-Content $file -Raw -ErrorAction Stop
                        # Step 5: Check if content is readable (non-binary)
                        if ($content -match '[\x00-\x08\x0B\x0C\x0E-\x1F]') {
                            $fullDiff += "[Binary file not displayed]"
                        } else {
                            $fullDiff += $content
                        }
                    }
                    catch {
                        # If we can't read the file, assume it's binary
                        $fullDiff += "[Binary file not displayed]"
                    }
                }
            }
            else {
                $fullDiff += "[File not found]"
            }

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