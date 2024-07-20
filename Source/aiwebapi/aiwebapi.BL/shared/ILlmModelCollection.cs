namespace aiwebapi.BL.shared;

public interface ILlmModelCollection
{
    Task<string> QueryAsync(string modelName, string prompt);
    IEnumerable<ILlmModel> ListModels();
}