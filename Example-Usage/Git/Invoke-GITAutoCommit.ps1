function Invoke-GITAutoCommit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = ".",
        
        [Parameter(Mandatory=$false)]
        [switch]$TestMode,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Anthropic", "OpenAI", "WebAPI")]
        [string]$AIProvider = "WebAPI",

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

        $basePrompt = "Please create me a good short commit message for the following git diff.
        Give me only the commit message and NOTHING else.
        Just a main message and then a few main points what the changes have been in bullet points.
        I want to use your complete output as commit message.
        The git diff is in base64.
        "

        $additionalInstructions = ""

        while ($true) {
            $prompt = $basePrompt + $additionalInstructions + "`n$encodedDiffBase64"

            $commitMessage = Invoke-AI -Provider $AIProvider -Prompt $prompt

            if ($null -eq $commitMessage) {
                Write-Error "Failed to generate commit message"
                return
            }

            Write-Host "Proposed commit message:`n$commitMessage`n"
            $choice = Read-Host "Choose an option: [A]ccept, [F]inetune, a[B]ort"

            switch ($choice.ToLower()) {
                'a' {
                    # Accept and proceed with git commands
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
                    return
                }
                'f' {
                    # Finetune the prompt
                    $additionalInstructions = Read-Host "Enter additional instructions for the AI"
                    $additionalInstructions = "`nAdditional instructions: $additionalInstructions`n"
                }
                'b' {
                    # Abort
                    Write-Host "Operation aborted."
                    return
                }
                default {
                    Write-Host "Invalid option. Please choose A, F, or B."
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

