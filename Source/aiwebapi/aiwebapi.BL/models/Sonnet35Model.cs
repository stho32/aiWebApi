using aiwebapi.BL.shared;

namespace aiwebapi.BL.models;

public class Sonnet35Model : ILlmModel
{
    private readonly string _anthropicApiKey;

    public Sonnet35Model(string anthropicApiKey)
    {
        _anthropicApiKey = anthropicApiKey;
    }

    public string ModelName => "Sonnet-3.5";
    public string Provider => "Anthropic";

    public async Task<string> QueryAsync(string prompt)
    {
        // TODO: Implement the actual API call to Anthropic's Sonnet 3.5 model
        // This is a placeholder implementation
        await Task.Delay(100); // Simulating API call
        return $"Sonnet 3.5 response to: {prompt}";
    }
}