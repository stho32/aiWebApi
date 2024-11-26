using System.Text.Json.Serialization;


namespace aiwebapi.BL.models.GPT4o;
public class OpenAIRequest
{
  [JsonPropertyName("model")]
  public string Model { get; set; } = null!;

  [JsonPropertyName("messages")]
  public Message[] Messages { get; set; } = null!;

  [JsonPropertyName("max_tokens")]
  public int MaxTokens { get; set; }

}



