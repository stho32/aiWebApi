# Requirements for AI Web API Project

- It retrieves ANTHROPIC API key from environment variables
- It has a single, simple endpoint for receiving prompts and returning AI responses
- It integrates with ANTHROPIC's API for processing prompts
- There is an OPENAPI swagger description for trying out the api
- It is designed to be multi-model capable in the future, allowing for integration with various AI models beyond ANTHROPIC

## Available Endpoints

1. POST /api/query
   - Receives a prompt and returns an AI-generated response
   - Accepts JSON payload with prompt text and optional parameters
   - Returns JSON response with generated text

2. GET /api/models
   - Lists available AI models (for future multi-model support)
   - Returns JSON array of model information

3. GET /swagger
   - Provides OpenAPI/Swagger documentation for trying out the API