using System.Net;
using System.Net.Http.Json;
using aiwebapi.BL.shared;

namespace aiwebapi.BL.models.Sonnet35;

public class Sonnet35Model : ILlmModel
{
    private readonly HttpClient _httpClient;
    private const string ApiUrl = "https://api.anthropic.com/v1/messages";
    private const string InternalModelName = "claude-3-5-sonnet-20240620";

    public Sonnet35Model(string anthropicApiKey)
    {
        _httpClient = new HttpClient();
        _httpClient.DefaultRequestHeaders.Add("x-api-key", anthropicApiKey);
        _httpClient.DefaultRequestHeaders.Add("anthropic-version", "2023-06-01");
    }

    public string ModelName => "Sonnet 3.5";
    public string Provider => "Anthropic";

    public async Task<string> QueryAsync(string prompt)
    {
        var request = new AnthropicRequest
        {
            Model = InternalModelName,
            Messages =
            [
                new Message { Role = "user", Content = prompt }
            ],
            MaxTokens = 1024
        };

        HttpResponseMessage response = await _httpClient.PostAsJsonAsync(ApiUrl, request);

        // Retry logic if the Response was HttpError 529.
        if (response.StatusCode == (HttpStatusCode)529)
        {
            response = await _httpClient.PostAsJsonAsync(ApiUrl, request);
        }

        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<AnthropicResponse>();
        return result?.Content?.FirstOrDefault()?.Text ?? "No response generated.";
    }
}