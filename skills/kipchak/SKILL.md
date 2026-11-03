---
name: kipchak
description: Builds and maintains PHP APIs with Kipchak, the API development kit on Slim 4 and FrankenPHP worker mode. Covers routes, controllers, DTOs with OpenAPI attributes, models, tests, configuration, drivers and middleware, and writing new drivers and middleware. Use when a project's composer.json requires kipchak/core, when the user mentions Kipchak, or when asked to build a lean, explicit PHP API with Kipchak.
license: MIT
---

# Kipchak

Kipchak is an API development kit for PHP 8.4 and later. It is Slim Framework 4 with a fixed structure: a boot
sequence, drivers for external services, middleware, and conventions for routes, controllers, data transfer objects
(DTOs) and OpenAPI. It runs on FrankenPHP in worker mode. Documentation: <https://kipchak.dev>; index for language
models: <https://kipchak.dev/llms.txt>.

**Kipchak is not Laravel or Symfony.** There are no facades, global helpers, service providers, Eloquent, Blade,
auto-wired controllers or hidden conventions. Everything an endpoint does is visible in the project's own code. Do
not write `request()`, `response()->json()`, `config('...')`, `app()`, `Route::get()`, `DB::`, `Cache::` or any
other framework helper: none of them exists here.

## Recognise a Kipchak project

`composer.json` requires `kipchak/core`, and the project has these folders. If the project has an `AGENTS.md`,
read it first: it describes that project.

| Path | Contains |
|---|---|
| `routes/` | Route files. Every `.php` file in it, at any depth, is loaded at boot. Versioned routes go in `routes/v1/`. |
| `api/Controllers/` | Controllers, namespace `Api\Controllers`; versioned ones in `v1/` (`Api\Controllers\v1`). |
| `api/DataTransferObjects/` | DTOs, versioned like the controllers. They are the API contract. |
| `api/Models/` | Business logic. |
| `api/Entities/Doctrine/<Connection>/` | Doctrine entities, when the Doctrine driver is used. |
| `api/Middlewares/` | The project's own PSR-15 middleware. |
| `api/OpenApi/Definition.php` | OpenAPI title, version, servers and shared responses. |
| `api/Utils/` | Code shared across the API. |
| `config/` | One PHP file per driver or middleware, returning an array, named `kipchak.<name>.php`. |
| `drivers/drivers.php` | Initialises the drivers, in order. |
| `middlewares/middlewares.php` | Initialises the middleware applied to every request: `Error::initialise($app)` first and last, everything else between. |
| `migrations/database/` | Plain SQL migrations for the Doctrine driver. |
| `html/index.php` | The FrankenPHP worker entry point. Rarely edited. |
| `tests/` | PHPUnit tests that boot the API and send requests to it. |

`Kipchak\Core\Api::boot()` builds the Slim application, then loads `drivers/drivers.php`, then
`middlewares/middlewares.php`, then every route file, and returns the application.

Commands in a project created from the starter (`composer create-project kipchak/starter my-api`):

* `composer test`: run the tests. Run them after every change.
* `composer openapi`: write the OpenAPI document to `openapi.yaml`; fails if the document has a problem.
* `docker compose up --watch`: run the API on <http://localhost:8080>, restarting the worker when a file changes.

## Rules

1. Start every PHP file in `api/` and `tests/` with `declare(strict_types=1);`. Make classes `final` unless they
   are meant to be extended. Type every property, parameter and return value.
2. **Controllers are thin.** Read the request, call a model, return a response. Logic belongs in `api/Models/`.
3. **DTOs are the contract.** Every request and response shape is a `final readonly` DTO with `#[OA\Schema]` and an
   `#[OA\Property]` (description and example) on each property. Controllers refer to DTO schemas with
   `ref: '#/components/schemas/Name'` and never define a DTO's fields inline. The same DTO describes the request
   body and the response.
4. **Responses** go through `Kipchak\Core\Components\Http\Response::json($response, $data, $status)`, which wraps
   `$data` in the envelope `{"code": 200, "status": "OK", "data": ...}`.
5. **Errors** are Slim's HTTP exceptions: `HttpNotFoundException`, `HttpBadRequestException`,
   `HttpUnauthorizedException`, `HttpForbiddenException`, `HttpMethodNotAllowedException`. The Error middleware
   (`kipchak/middleware-error`) turns them into the same envelope, for example
   `{"code": 404, "status": "RESOURCE_NOT_FOUND", "data": "No order has the ID 9."}`. Any other exception becomes a
   500 whose message the client does not see.
6. **Worker mode.** The API is booted once and serves many requests from memory. Never keep request data in a
   static property, a global or a singleton. A static may only cache what is the same for every request.
7. **Use a Kipchak driver** for a service when one exists, rather than a client library directly (see
   [references/packages.md](references/packages.md)). Relational databases use the Doctrine driver.
8. **Configuration** lives in `config/` and environment variables. Read a config file with
   `Kipchak\Driver\Config\Config::get('kipchak.api')`, which returns an array. Read environment variables inside
   config files with `Kipchak\Core\env('NAME', 'default')`. Never call `getenv()` in controllers or models.
9. **Logging** in a controller uses `$this->logger` (Monolog, PSR-3); elsewhere `Kipchak\Driver\Logger\Logger::get()`.
10. **An API change is a contract change.** Update the DTO and the controller's attributes together, then the
    tests, and check the OpenAPI document still generates without warnings.

## Adding an endpoint

Follow these five steps. The full code for each is in [references/endpoints.md](references/endpoints.md); read it
before writing an endpoint.

1. **DTO** in `api/DataTransferObjects/v1/`.
2. **Model** in `api/Models/`: the logic, returning DTOs. Map arrays to DTOs with Valinor:
   `(new MapperBuilder())->mapper()->map(Order::class, Source::array($row))`.
3. **Controller method** in `api/Controllers/v1/`, on a class extending `Kipchak\Core\Components\Controllers\Base`,
   with the signature `(ServerRequestInterface $request, ResponseInterface $response, array $args): ResponseInterface`
   and an `#[OA\Get]`, `#[OA\Post]` (and so on) attribute: path, `operationId`, summary, tags, parameters, request
   body and responses.
4. **Route** in `routes/v1/<resource>.php`, inside a `/v1` group:
   `$group->get('/orders/{id:[0-9]+}', [Controllers\v1\Orders::class, 'get']);`
5. **Test** in `tests/`, extending the project's `ApiTestCase`, for the success and the error responses. If the
   project's OpenAPI test lists the expected paths, add the new path there.

## References

Read the reference that matches the task:

* [references/endpoints.md](references/endpoints.md): a complete resource (DTO, model, controller, route, test),
  request bodies and validation, query parameters, path parameters.
* [references/drivers.md](references/drivers.md): using drivers, configuration, Doctrine, and writing a new driver.
* [references/middleware.md](references/middleware.md): global, group and route middleware, their order, and
  writing new middleware.
* [references/worker-mode.md](references/worker-mode.md): what is safe in a long-lived worker, request bodies,
  connections, and work after the response.
* [references/packages.md](references/packages.md): every Kipchak driver and middleware, free and Enterprise.
