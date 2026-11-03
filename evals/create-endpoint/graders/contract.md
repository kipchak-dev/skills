---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the request and response shape is a DTO class with OpenAPI schema attributes, and the POST operation documents its request body (OA\RequestBody) and response by referencing that schema, not by defining fields inline.
