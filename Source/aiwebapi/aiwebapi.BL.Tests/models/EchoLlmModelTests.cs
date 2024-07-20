using aiwebapi.BL.models;
using aiwebapi.BL.shared;
using NUnit.Framework;

namespace aiwebapi.BL.Tests.models;

[TestFixture]
public class EchoLlmModelTests
{
    [Test]
    public async Task QueryAsync_ShouldReturnSamePrompt()
    {
        var model = new EchoLlmModel();
        string prompt = "Test prompt";
        string result = await model.QueryAsync(prompt);
        Assert.That(result, Is.EqualTo(prompt));
    }

    [Test]
    public async Task LlmModelCollection_QueryEchoModel_ShouldReturnSamePrompt()
    {
        var echoModel = new EchoLlmModel();
        var collection = new LlmModelCollection(new ILlmModel[] { echoModel });

        string prompt = "Hello, Echo!";
        string result = await collection.QueryAsync("Echo", prompt);
        Assert.That(result, Is.EqualTo(prompt));
    }

    [Test]
    public void LlmModelCollection_ListModels_ShouldContainEchoModel()
    {
        var echoModel = new EchoLlmModel();
        var collection = new LlmModelCollection(new ILlmModel[] { echoModel });

        var models = collection.ListModels();
        var llmModels = models as ILlmModel[] ?? models.ToArray();
        
        Assert.That(llmModels, Contains.Item(echoModel));
        Assert.That(llmModels.Count(), Is.EqualTo(1));
    }
}