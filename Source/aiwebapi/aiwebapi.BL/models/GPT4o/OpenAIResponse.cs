using System.Text.Json.Serialization;


namespace aiwebapi.BL.models.GPT4o;

public class OpenAIResponse
{
    [JsonPropertyName("choices")]
    public Content[] Content { get; set; } = null!;

}

