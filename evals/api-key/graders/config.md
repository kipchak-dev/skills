---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the expected key is read from a config/ file through Kipchak\Driver\Config\Config::get() or with Kipchak env() helper in a config file, and not with getenv(), $_ENV or $_SERVER inside the middleware or controller, and nothing request-specific is kept in a static property.
