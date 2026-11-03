---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the request body is read once (for example (string) $request->getBody() or $request->getParsedBody()), and validation is done by mapping into the DTO or by explicit checks in a model, not by reading the body stream repeatedly.
