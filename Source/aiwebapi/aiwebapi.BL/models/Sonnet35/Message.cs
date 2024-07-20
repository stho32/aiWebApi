using System.Text.Json.Serialization;

namespace aiwebapi.BL.models.Sonnet35;

public class Message
{
    [JsonPropertyName("role")]
    public string Role { get; set; } = null!;

    [JsonPropertyName("content")]
    public string Content { get; set; } = null!;
}