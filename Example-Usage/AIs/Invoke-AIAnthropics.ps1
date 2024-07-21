function Invoke-AIAnthropics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("claude-3-5-sonnet-20240620")]
        [string]$ModelName = "claude-3-5-sonnet-20240620",
        
        [Parameter(Mandatory=$true)]
        [string]$Prompt
    )

    $apiKey = $env:ANTHROPIC_API_KEY
    if (-not $apiKey) {
        Write-Error "ANTHROPIC_API_KEY environment variable is not set"
        return $null
    }

    $headers = @{
        "x-api-key" = $apiKey
        "anthropic-version" = "2023-06-01"
        "content-type" = "application/json"
    }

    $body = @{
        model = $ModelName
        max_tokens = 1024
        messages = @(
            @{
                role = "user"
                content = $Prompt
            }
        )
    } | ConvertTo-Json

    $apiUrl = "https://api.anthropic.com/v1/messages"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
        return $response.content[0].text.Trim()
    }
    catch {
        Write-Error "Failed to call Anthropic API: $_"
        return $null
    }
}