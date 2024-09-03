using aiwebapi.BL.models;
using aiwebapi.BL.models.GPT4o;
using aiwebapi.BL.models.Sonnet35;
using aiwebapi.BL.shared;

namespace aiwebapi.BL;

public class LlmModelCollectionFactory
{
    public static ILlmModelCollection Create(Dictionary<string, string> apiKeys)
    {
        var models = new List<ILlmModel>
    {
        new EchoLlmModel()
    };

        if (apiKeys.TryGetValue("Sonnet35", out var sonnetApiKey))
        {
            models.Add(new Sonnet35Model(sonnetApiKey));
        }

        if (apiKeys.TryGetValue("Gpt4o", out var gpt4oApiKey))
        {
            models.Add(new Gpt4oModel(gpt4oApiKey));
        }

        return new LlmModelCollection(models.ToArray());
    }
}