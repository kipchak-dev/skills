---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the code follows the Kipchak layout: routes in a file under routes/ (in a /v1 group), a thin controller under api/Controllers/v1 extending Kipchak\Core\Components\Controllers\Base, and the data logic in a model under api/Models. Fail if logic lives in the route file or the controller holds the data.
