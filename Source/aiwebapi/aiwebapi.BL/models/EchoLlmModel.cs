using aiwebapi.BL.shared;

namespace aiwebapi.BL.models;

public class EchoLlmModel : ILlmModel
{
    public string ModelName => "Echo";
    public string Provider => "Local";

    public Task<string> QueryAsync(string prompt)
    {
        return Task.FromResult(prompt);
    }
}