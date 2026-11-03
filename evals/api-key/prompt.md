---
max_turns: 40
timeout_seconds: 900
tags: [kipchak]
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Skill]
---

This is a PHP API. Require an API key on every endpoint under /v1: a request must send an X-Api-Key header equal to the value of the API_KEY environment variable, or it receives a 401 response in the API's usual error format. The /status endpoint stays open. Add tests, and make sure the whole test suite passes.
