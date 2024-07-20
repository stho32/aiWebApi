# AI Web API Project

A .NET 8 application providing an API for interacting with AI models, primarily Anthropic's Claude API.

## Features

- Endpoint for querying AI models
- Multi-model support (Claude 3.5 Sonnet and Echo model)
- OpenAPI/Swagger documentation
- GitHub Actions CI/CD workflow
- PowerShell script for AI-generated Git commits

## Prerequisites

- .NET 8 SDK
- Anthropic API key

## Setup

1. Clone the repository
2. Set environment variable: `ANTHROPIC_API_KEY="your-api-key"`
3. Navigate to `Source/aiwebapi`
4. Run: `dotnet restore` and `dotnet run --project aiwebapi.webapi`

## API Endpoints

- GET /models: List available AI models
- POST /query: Send prompt to specified AI model

Explore via Swagger UI: `https://localhost:5001/swagger`

## Automated Git Commits

Use the PowerShell script for AI-generated commit messages:

```powershell
.\Example-Usage\Invoke-GitAutoCommit.ps1
```

## Project Structure

```
Source/aiwebapi/
├── aiwebapi.BL/             # Business Logic
├── aiwebapi.BL.Tests/       # Unit tests
└── aiwebapi.webapi/         # Web API
```

## License

MIT License