using System.Text.Json.Serialization;

namespace aiwebapi.BL.models.Sonnet35;

public class Content
{
    [JsonPropertyName("text")]
    public string Text { get; set; } = null!;
}