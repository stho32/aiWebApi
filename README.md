# .NET 6 App Repository Template

This project template is designed for .NET 8 applications.

## Badges

- [ ] Add a badge from the build workflow

## What is this?

This is a template repository for creating .NET 8 applications with a predefined structure and workflow. It includes:

- A solution structure with separate projects for business logic and unit tests
- GitHub Actions workflow for building, testing, and publishing
- Scripts for creating new projects and running tests with code coverage
- MIT License

### Features

- Automated project creation with `New-Project.ps1`
- Cross-platform support (Windows and Linux)
- Integrated unit testing with NUnit
- Code coverage reporting
- Continuous Integration/Continuous Deployment (CI/CD) setup with GitHub Actions

### Getting Started

1. Clone this repository
2. Run the `New-Project.ps1` script to create a new project:
   ```
   .\New-Project.ps1 -ProjectName YourProjectName
   ```