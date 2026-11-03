---
max_turns: 40
timeout_seconds: 900
tags: [kipchak]
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Skill]
---

Our company has an internal pricing service. Its base URL is in the PRICING_URL environment variable, and GET /prices/{sku} returns JSON such as {"sku": "A1", "price": 9.5}. Write a reusable Kipchak driver for it in this project, so that any controller can get a client for the service, and register it. Do not call the real service. The existing tests must still pass.
