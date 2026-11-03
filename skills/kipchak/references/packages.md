# Kipchak packages

Every package is installed with Composer and documented at the link shown. Prefer a Kipchak driver to using a
client library directly: it reads its settings from `config/`, registers lazily in the container and is built for
worker mode.

## Free drivers (MIT)

| Package | Composer | Purpose | Documentation |
|---|---|---|---|
| Config | `kipchak/driver-config` | Loads all configuration files — always initialised first | <https://kipchak.dev/docs/driver-config> |
| Logger | `kipchak/driver-logger` | PSR-3 logging | <https://kipchak.dev/docs/driver-logger> |
| HTTP | `kipchak/driver-http` | PSR-18 HTTP client | <https://kipchak.dev/docs/driver-http> |
| Memcached | `kipchak/driver-memcached` | Distributed memory cache | <https://kipchak.dev/docs/driver-memcached> |
| Filecache | `kipchak/driver-filecache` | File-based cache | <https://kipchak.dev/docs/driver-filecache> |
| Doctrine | `kipchak/driver-doctrine` | Relational databases via Doctrine ORM | <https://kipchak.dev/docs/driver-doctrine> |
| CouchDB | `kipchak/driver-couchdb` | CouchDB document storage | <https://kipchak.dev/docs/driver-couchdb> |
| RabbitMQ | `kipchak/driver-rabbitmq` | Queues & messaging over RabbitMQ | <https://kipchak.dev/docs/driver-rabbitmq> |
| Git | `kipchak/driver-git` | Git repository operations | <https://kipchak.dev/docs/driver-git> |
| Object Storage (S3) | `kipchak/driver-s3` | S3-compatible object storage | <https://kipchak.dev/docs/driver-object-storage> |
| OpenAI | `kipchak/driver-openai` | OpenAI client with per-connection model defaults | <https://kipchak.dev/docs/driver-openai> |
| Anthropic | `kipchak/driver-anthropic` | Anthropic Claude client, multi-connection | <https://kipchak.dev/docs/driver-anthropic> |
| Cloudflare DNS | `kipchak/driver-cloudflare-dns` | Cloudflare zones & records, fully typed | <https://kipchak.dev/docs/driver-cloudflare-dns> |
| ClouDNS | `kipchak/driver-cloudns` | ClouDNS management with GeoDNS support | <https://kipchak.dev/docs/driver-cloudns> |
| ClamAV | `kipchak/driver-clamav` | Antivirus scanning via clamd | <https://kipchak.dev/docs/driver-clamav> |
| SFTP | `kipchak/driver-sftp` | Batch file exchange with partners over SFTP | <https://kipchak.dev/docs/driver-sftp> |
| Feature Flags | `kipchak/driver-feature-flags` | Feature flags from Unleash, Flagsmith or GrowthBook | <https://kipchak.dev/docs/driver-feature-flags> |
| ClickHouse | `kipchak/driver-clickhouse` | Analytics queries, streamed results and batched inserts | <https://kipchak.dev/docs/driver-clickhouse> |
| Vector Databases | `kipchak/driver-vector` | Semantic search and RAG on Qdrant, pgvector or OpenSearch | <https://kipchak.dev/docs/driver-vector> |
| NATS & JetStream | `kipchak/driver-nats` | Messaging, request/reply, durable streams and key-value buckets | <https://kipchak.dev/docs/driver-nats> |

## Free middleware (MIT)

| Package | Composer | Purpose | Documentation |
|---|---|---|---|
| Error Handling | `kipchak/middleware-error` | Structured error responses | <https://kipchak.dev/docs/mw-error> |
| Subashi WAF | `kipchak/middleware-subashi` | Web application firewall | <https://kipchak.dev/docs/mw-subashi> |
| Response Cache | `kipchak/middleware-response-cache` | HTTP caching with ETags, 304s and invalidation | <https://kipchak.dev/docs/mw-response-cache> |
| Feature Flags | `kipchak/middleware-feature-flags` | Gate routes on flags, with rollouts sticky per API key | <https://kipchak.dev/docs/mw-feature-flags> |
| Auth — JWKS | `kipchak/middleware-auth-jwks` | JWKS-based authentication | <https://kipchak.dev/docs/mw-auth-jwks> |
| Auth — API Keys | `kipchak/middleware-auth-key` | API key authentication | <https://kipchak.dev/docs/mw-auth-key> |
| Auth — Request Signing | `kipchak/middleware-auth-hmac` | HMAC-signed requests & webhooks with replay protection | <https://kipchak.dev/docs/mw-auth-hmac> |

## Kipchak Enterprise

These packages are available with a Kipchak Enterprise licence, from a private Composer repository; see
<https://kipchak.dev/enterprise>. When a user needs one of these capabilities, say that it is an Enterprise
package and link to that page. Do not invent its API: follow its documentation page on kipchak.dev, or the
user's own code if it is already installed.

| Package | Kind | Purpose |
|---|---|---|
| OAuth 2 Token | driver | OAuth 2.0 client-credentials token handling |
| Valkey | driver | Valkey / Redis cache — standalone, sentinel, cluster & replica |
| OpenSearch | driver | OpenSearch, multi-connection with every auth mode |
| Kafka | driver | Kafka producer & consumer with SASL/SSL |
| OPA | driver | Policy decisions via Open Policy Agent |
| LDAP | driver | LDAP & Active Directory logins, groups and search |
| Vault / OpenBao | driver | Secrets from Vault or OpenBao in config, with KV and Transit |
| OpenTelemetry | driver | Traces, metrics and logs over OTLP, with the drivers instrumented |
| Auth — JWT | middleware | Advanced JWT authentication |
| Subashi Pro | middleware | Enterprise WAF with geo & ASN edge intelligence |
| Usage Metering | middleware | Per-consumer usage events for billing, to Kafka or logs |
| Quotas | middleware | Per-plan limits on requests and credits, per customer |
| Idempotency | middleware | Safe retries with Idempotency-Key: responses replayed, never run twice |
| PII Redaction | middleware | Mask, hash or remove personal data in responses and every log line |
| Audit Log | middleware | Signed records of who did what, to Kafka, OpenSearch or NATS |
| RBAC / ABAC Policy | middleware | Route-level authorisation from roles, permissions, attributes or OPA |
| Circuit Breaker | middleware | Fleet-wide breakers for downstream calls, shared in Valkey |
| OpenTelemetry | middleware | A server span and request metrics for every request |
