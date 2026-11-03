---
max_turns: 40
timeout_seconds: 900
tags: [kipchak]
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Skill]
---

This is a PHP API. Add an endpoint that creates a book from a JSON request body with a title, an author and the year it was published, and returns the new book with its ID. Reject a body that is not valid JSON, or that has no title or author, with a 400 response in the API's usual error format. Keep the books in memory for now. Add tests, and make sure the whole test suite passes.
