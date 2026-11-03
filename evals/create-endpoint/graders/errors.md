---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if invalid input (malformed JSON, or a missing title or author) is rejected by throwing Slim\Exception\HttpBadRequestException (or another Slim HTTP exception), not by building an error response by hand, and the success response uses Http\Response::json with status 201.
