using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using aiwebapi.BL.shared;

namespace aiwebapi.BL.models.GPT4o;

public class Gpt4oModel : ILlmModel
{
  private readonly HttpClient _httpClient;
  private const string ApiUrl = "https://api.openai.com/v1/chat/completions";
  private const string InternalModelName = "gpt-4o";

  public Gpt4oModel(string openAiApiKey)
  {
    _httpClient = new HttpClient();
    _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {openAiApiKey}");
    _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
  }

  public string ModelName => "GPT 4o";
  public string Provider => "OpenAI";

  public async Task<string> QueryAsync(string prompt)
  {
    var requestBody = new OpenAIRequest
    {
      Model = InternalModelName,
      Messages =
      [
          new Message { Role = "user", Content = prompt }
      ],
      MaxTokens = 1024
    };

    HttpResponseMessage response = await _httpClient.PostAsJsonAsync(ApiUrl, requestBody);

    // Retry logic if the Response was HttpError 529.
    if (response.StatusCode == (HttpStatusCode)529)
    {
      response = await _httpClient.PostAsJsonAsync(ApiUrl, requestBody);
    }

    response.EnsureSuccessStatusCode();

    var result = await response.Content.ReadFromJsonAsync<OpenAIResponse>();
    return result?.Content?.FirstOrDefault()?.Message?.Content ?? "No response generated.";
  }
}
