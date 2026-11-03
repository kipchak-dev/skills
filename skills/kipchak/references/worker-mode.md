# Worker mode

A Kipchak API runs on FrankenPHP in worker mode: each worker boots the application once
(`html/index.php` calls `Api::boot()`) and then serves thousands of requests from memory. That is what makes it
fast, and it changes what is safe.

## State

* **Never keep request data in a static property, a global, a singleton or a class constant that is written at run
  time.** It leaks into the next request on that worker, possibly another user's. Keep it in the request
  (`withAttribute()`), in local variables and in objects created for the request.
* A static may cache what is the same for every request, such as a generated OpenAPI document or a parsed
  configuration file.
* Route closures are re-bound per request, so a `static` variable inside a closure does not persist.
* Create models and DTOs per request (`new Orders()` in the controller method). They are cheap.

## Connections

* Drivers create connections lazily, on first use, and keep them for the worker's life. A database, cache or
  broker can restart while the worker lives on, so a client must recover: Kipchak's drivers do, and a driver you
  write must reconnect after a lost connection rather than fail every later request on that worker.
* With Doctrine, clear the entity manager at the start of each request and replace a lost connection; the
  starter's `html/index.php` has the lines to uncomment.

## The request body

* Read the body once: `$body = (string) $request->getBody();`. The worker's `html/index.php` adds Slim's body
  parsing middleware, so JSON bodies are also available from `$request->getParsedBody()`.
* A middleware that needs the body (to verify a signature or fingerprint a request) must read it once and give
  the handler a request with a fresh stream holding the same content:
  `$request->withBody((new StreamFactory())->createStream($body))`. Reading Slim's stream again after rewinding
  it can return the content twice.

## After the response

* Work that should not delay the response (exporting telemetry, for example) is registered with
  `$app->onTerminate()` and runs after the response is sent, in the worker loop.
* An idle worker runs nothing: work queued for later waits for that worker's next request.
* The worker calls `gc_collect_cycles()` after every request, so large structures kept between requests make every
  request slower. Keep long-lived buffers small and bounded.

## Development

* `docker compose up --watch` restarts the worker when a file changes. Without it, a change is not seen until the
  worker restarts.
* `html/index.nonworker.php` serves the API without worker mode, for debugging a suspected state leak.
* `MAX_REQUESTS` (default 10,000) recycles a worker after that many requests.
