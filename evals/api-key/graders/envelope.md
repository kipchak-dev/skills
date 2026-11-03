---
type: llm
focus: trace
---
Judge only the code the agent itself wrote or changed (the contents of its Write and Edit tool calls), not files it read. Pass if a missing or wrong key produces a 401 in the API JSON envelope ({"code", "status", "data"}) by throwing Slim\Exception\HttpUnauthorizedException (or through the package), and the code ensures the Error middleware handles it: the check is attached to the /v1 route group, or it is registered in middlewares/middlewares.php with Error::initialise($app) after it.
