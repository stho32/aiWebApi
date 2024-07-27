function Get-AICommitSummary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$StartCommit,

        [Parameter(Mandatory=$true)]
        [string]$EndCommit,

        [Parameter(Mandatory=$false)]
        [string]$Path = "."
    )

    try {
        Push-Location $Path

        # Validate if the provided hashes are valid commits
        $validStartCommit = git rev-parse --verify $StartCommit 2>$null
        $validEndCommit = git rev-parse --verify $EndCommit 2>$null

        if (-not $validStartCommit -or -not $validEndCommit) {
            throw "Invalid commit hash provided"
        }

        # Get the list of commits between StartCommit and EndCommit
        $commits = git log --reverse --format="%H" "$StartCommit^..$EndCommit"

        $summaries = @()

        foreach ($commit in $commits) {
            # Get commit details
            $commitDetails = Get-GITCommitDescription -CommitHash $commit -Path $Path

            # Prepare prompt for AI
            $prompt = @"
Give me details for the following change, so I can later summarize the information for a normal user of the software.
Please give me ONLY the details, nothing else.

$commitDetails
"@

            # Call Invoke-AIWebAPI
            #$aiSummary = Invoke-AIWebAPI -Prompt $prompt
            $aiSummary = Invoke-AIAnthropics -Prompt $prompt

            # Store the summary
            $summaries += @{
                CommitHash = $commit
                AISummary = $aiSummary
            }

            # Output progress
            Write-Progress -Activity "Analyzing commits" -Status "Processed commit $commit" -PercentComplete (($summaries.Count / $commits.Count) * 100)
        }

        return $summaries
    }
    catch {
        Write-Error "An error occurred while getting AI commit summaries: $_"
        return $null
    }
    finally {
        Pop-Location
    }
}