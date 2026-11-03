---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the book is a DTO class (final readonly, constructor-promoted properties) with #[OA\Schema] and an #[OA\Property] with a description and example on each property, and the controller operations reference it with ref: "#/components/schemas/..." instead of defining the fields inline.
