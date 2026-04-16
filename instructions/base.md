# Project Guidelines

## General Principles

- Write clean, readable, maintainable code
- Follow existing patterns in the codebase
- Prefer simplicity over cleverness
- Keep functions small and focused (under 20 lines when possible)
- Use descriptive names for variables, functions, and classes

## Code Style

- Use consistent indentation (follow project settings)
- Prefer `const` over `let`, avoid `var`
- Use meaningful variable names (avoid single letters except for loops)
- Add comments only when the "why" isn't obvious from the code

## Error Handling

- Always handle errors explicitly
- Provide meaningful error messages
- Never swallow exceptions silently
- Use appropriate error types for the language

## Security

- Never hardcode secrets, API keys, or passwords
- Validate all user input
- Use parameterized queries for database operations
- Follow the principle of least privilege

## Testing

- Write tests for new functionality
- Maintain existing test coverage
- Test edge cases and error conditions
- Keep tests focused and independent

## Git Commits

- Write clear, concise commit messages
- Use present tense ("Add feature" not "Added feature")
- Reference issue numbers when applicable
- Keep commits atomic and focused
