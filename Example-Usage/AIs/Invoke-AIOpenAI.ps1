function Invoke-OpenAI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "gpt-4-turbo",
            "gpt-4",
            "gpt-4o"
        )]
        [string]$ModelName = "gpt-4-turbo",
        
        [Parameter(Mandatory=$true)]
        [string]$Prompt,

        [Parameter(Mandatory=$false)]
        [int]$MaxTokens = 1000,

        [Parameter(Mandatory=$false)]
        [double]$Temperature = 0.7
    )

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        throw "Die Umgebungsvariable OPENAI_API_KEY ist nicht gesetzt."
    }

    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
    }

    $body = @{
        model = $ModelName
        messages = @(
            @{
                role = "user"
                content = $Prompt
            }
        )
        max_tokens = $MaxTokens
        temperature = $Temperature
    } | ConvertTo-Json

    $apiUrl = "https://api.openai.com/v1/chat/completions"

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content.Trim()
    }
    catch {
        Write-Error "Fehler beim Aufruf der OpenAI API: $_"
        return $null
    }
}
