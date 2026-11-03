---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the request and response shape is a DTO class with OpenAPI schema attributes, and the POST operation documents its request body (OA\RequestBody) and response by referencing that schema, not by defining fields inline. The response envelope (its code, status and data properties) is defined inline in every Kipchak operation and does not count: only the book's own fields must not be repeated inline.
