using System.Text.Json.Serialization;


namespace aiwebapi.BL.models.GPT4o;

public class Content
{
    [JsonPropertyName("content")]
    public int Index { get; set; }
    public Message Message { get; set; } = null!;
}

