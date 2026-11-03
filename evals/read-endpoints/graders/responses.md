---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the controller returns responses with Kipchak\Core\Components\Http\Response::json(...) and reports an unknown ID by throwing Slim\Exception\HttpNotFoundException, rather than building error responses or JSON by hand.
