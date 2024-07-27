function Get-GITCommitDescription {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$Path = ".",
        [Parameter(Mandatory=$true)]
        [string]$CommitHash
    )
    try {
        Push-Location $Path
        # Validate if the provided hash is a valid commit
        $validCommit = git rev-parse --verify $CommitHash 2>$null
        if (-not $validCommit) {
            throw "Invalid commit hash: $CommitHash"
        }
        # Get the commit message
        $commitMessage = git log -1 --pretty=format:"%s%n%n%b" $CommitHash
        # Get the diff of the commit without author and date information
        $diffOutput = git show --no-patch --format="" --stat $CommitHash
        
        # Check if the commit is a merge commit
        $isMergeCommit = git rev-parse --verify "$CommitHash^2" 2>$null
        if ($isMergeCommit) {
            # For merge commits, show the diff between the merge commit and its first parent
            $patchOutput = git diff-tree -p --cc $CommitHash
        } else {
            $patchOutput = git show -p --no-prefix --format="" $CommitHash
        }

        # Combine the commit message and diff output using an array
        $fullDescription = @(
            "Commit: $CommitHash"
            "Commit Message:"
            $commitMessage
            "Changes:"
            $diffOutput
            "Patch:"
            $patchOutput
        )

        # Join the array elements with newlines
        return $fullDescription -join "`n"
    }
    catch {
        Write-Error "An error occurred while getting the commit description: $_"
        return $null
    }
    finally {
        Pop-Location
    }
}