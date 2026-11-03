---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if the driver implements Kipchak\Core\Interfaces\Driver with static initialise(ContainerInterface $container, ?string $configFileName = null), set() and get().
