using System.Text.Json.Serialization;

namespace aiwebapi.BL.models.Sonnet35;

public class AnthropicResponse
{
    [JsonPropertyName("content")]
    public Content[] Content { get; set; } = null!;
}