using aiwebapi.BL.models;
using aiwebapi.BL.models.Sonnet35;
using aiwebapi.BL.shared;

namespace aiwebapi.BL;

public class LlmModelCollectionFactory
{
    public static ILlmModelCollection Create(string anthropicApiKey)
    {
        return new LlmModelCollection(
            new ILlmModel[] { 
                new EchoLlmModel(),
                new Sonnet35Model(anthropicApiKey)
            }
        );
    }
}