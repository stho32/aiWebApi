function Invoke-AIWebApi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$ApiUrl = "http://localhost:5000",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Echo", "Sonnet 3.5")]
        [string]$ModelName = "Sonnet 3.5",

        [Parameter(Mandatory=$true)]
        [string]$Prompt
    )

    $body = @{
        ModelName = $ModelName
        Prompt = $Prompt
    } | ConvertTo-Json

    Write-Verbose $body 

    $url = "$ApiUrl/query"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
        return $response.Response.Trim()
    }
    catch {
        Write-Error "Failed to call AI Web API: $_"
        return $null
    }
}