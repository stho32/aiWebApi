function Get-GitDiff {
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

function Invoke-GitAutoCommit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = ".",
        
        [Parameter(Mandatory=$false)]
        [string]$ApiUrl = "http://localhost:5295/query",
        
        [Parameter(Mandatory=$false)]
        [string]$ModelName = "Sonnet 3.5",

        [Parameter(Mandatory=$false)]
        [switch]$TestMode,

        [Parameter(Mandatory=$false)]
        [switch]$AutoPush
    )

    # Save the current ErrorActionPreference
    $oldErrorActionPreference = $ErrorActionPreference

    try {
        # Set ErrorActionPreference to Stop for this function
        $ErrorActionPreference = "Stop"

        # Get git diff using the new cmdlet
        $gitDiff = Get-GitDiff -Path $Path

        if ($null -eq $gitDiff) {
            return
        }

        # Encode the git diff to ensure it's valid UTF-8
        $encodedDiff = [System.Text.Encoding]::UTF8.GetBytes($gitDiff)
        $encodedDiffBase64 = [System.Convert]::ToBase64String($encodedDiff)

        # Prepare the request body
        $body = @{
            ModelName = $ModelName
            Messages = @(
                @{
                    role = "user"
                    content = "Please create me a good short commit message for the following git diff (base64 encoded). Give me only the commit message and NOTHING else. Just a main message and then a few main points what the changes have been in bullet points. I want to use your complete output as commit message. Here's the base64 encoded git diff: $encodedDiffBase64"
                }
            )
        }

        # Prepare the request body
        $body = @{
            ModelName = $ModelName
            Prompt = "Please create me a good short commit message for the following git diff.
            Give me only the commit message and NOTHING else.
            Just a main message and then a few main points what the changes have been in bullet points.
            I want to use your complete output as commit message.
            The git diff is in base64.
            
            `n$encodedDiffBase64
            "
        } | ConvertTo-Json

        Write-Verbose $body 

        # Make the API call
        $response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $body -ContentType "application/json"

        # Extract the commit message from the response
        $commitMessage = $response.Response.Trim()

        if ($TestMode) {
            Write-Host "Test Mode: Would commit with message:`n$commitMessage"
        } else {
            # Run git add .
            try {
                $null = & git -C $Path add . 2>&1
                Write-Host "Changes staged successfully."
            } catch {
                # Ignore the error and continue
            }

            # Run git commit with the generated message
            try {
                $escapedMessage = $commitMessage -replace '"', '\"'
                $null = & git -C $Path commit -m "$escapedMessage" 2>&1
                Write-Host "Committed changes with message:`n$commitMessage"
            } catch {
                # Ignore the error and continue
            }

            if ($AutoPush) {
                try {
                    $null = & git -C $Path push 2>&1
                    Write-Host "Changes pushed to remote repository."
                } catch {
                    # Ignore the error and continue
                }
            }
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    finally {
        # Restore the original ErrorActionPreference
        $ErrorActionPreference = $oldErrorActionPreference
    }
}
