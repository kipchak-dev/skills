---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if its settings come from a config/kipchak.<name>.php file read with Kipchak\Driver\Config\Config::get() (which returns an array), with the URL taken from the environment through Kipchak env() helper in that config file.
