using aiwebapi.BL;
using aiwebapi.BL.shared;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var apiKeys = new Dictionary<string, string>
{
    { "Sonnet35", Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY") ?? string.Empty },
    { "Gpt4o", Environment.GetEnvironmentVariable("OPENAI_API_KEY") ?? string.Empty }
};

builder.Services.AddSingleton(LlmModelCollectionFactory.Create(apiKeys));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// List available models
app.MapGet("/models", (ILlmModelCollection modelCollection) =>
{
    var models = modelCollection.ListModels().Select(m => new { m.ModelName, m.Provider });
    return Results.Ok(models);
})
.WithName("ListModels")
.WithOpenApi();

// Query a specific model
app.MapPost("/query", async (QueryRequest request, ILlmModelCollection modelCollection) =>
{
    try
    {
        var response = await modelCollection.QueryAsync(request.ModelName, request.Prompt);
        return Results.Ok(new { Response = response });
    }
    catch (ArgumentException ex)
    {
        return Results.BadRequest(new { Error = ex.Message });
    }
})
.WithName("QueryModel")
.WithOpenApi();

app.Run();