using aiwebapi.BL.shared;

namespace aiwebapi.BL;

public class LlmModelCollection(ILlmModel[] models) : ILlmModelCollection
{
    public async Task<string> QueryAsync(string modelName, string prompt)
    {
        var model = models.FirstOrDefault(m => string.Equals(m.ModelName, modelName, StringComparison.OrdinalIgnoreCase));
        if (model == null)
        {
            throw new ArgumentException($"Model '{modelName}' not found.", nameof(modelName));
        }
        return await model.QueryAsync(prompt);
    }

    public IEnumerable<ILlmModel> ListModels()
    {
        return models;
    }
}