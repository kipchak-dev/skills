# Middleware

Kipchak middleware is PSR-15 middleware on Slim 4. A Kipchak middleware package also provides a static
`initialise(App $app)` that reads its `config/` file and adds itself to the application.

## Global middleware

`middlewares/middlewares.php` initialises the middleware applied to every request:

```php
<?php

use Kipchak\Middleware\Auth\Key\Key;
use Kipchak\Middleware\Error\Error;
use Kipchak\Middleware\Subashi\Subashi;
use Slim\App;

/**
 * @var App $app
 */

Error::initialise($app);   // innermost: turns route exceptions into JSON responses
Key::initialise($app);
Subashi::initialise($app);
Error::initialise($app);   // outermost: does the same for exceptions from the middleware above
```

**Slim runs the middleware added last first.** Initialise the Error middleware twice, as the first and the last
line, with every other global middleware between the two:

* The first is the innermost middleware. It turns an exception from a route into the JSON error envelope, so that
  middleware observing responses (OpenTelemetry, Metering, Redaction, Idempotency) sees a response.
* The last is the outermost. It turns an exception thrown by any other middleware (an `HttpUnauthorizedException`
  from an authentication check, for example) into the same envelope. Without it, that exception reaches the client
  as a plain-text 500.

In the example above a request passes through the outer Error, then Subashi, then Key, then the inner Error, then
the route. Projects created from the starter have a test, `tests/MiddlewareOrderTest.php`, that fails if Error is
not the outermost.

## Group and route middleware

Attach middleware to a route group, or to a single route, with `add()`. Group and route middleware run after the
global middleware, nearest the controller:

```php
$app->group('/v1/admin', function (RouteCollectorProxy $group) {
    $group->get('/reports', [Controllers\v1\Reports::class, 'list']);
})->add(new RequireRole('admin'));

$app->get('/v1/exports/{id:[0-9]+}', [Controllers\v1\Exports::class, 'get'])
    ->add(new RequireRole('auditor'));
```

Some packages expose their handler for this purpose; for example the JWKS middleware's
`new AuthJWKS($app->getContainer(), ['email'])` on a group. Each package's documentation page shows how.

## Writing middleware

Project middleware lives in `api/Middlewares/`:

```php
<?php

declare(strict_types=1);

namespace Api\Middlewares;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Exception\HttpForbiddenException;

final readonly class RequireRole implements MiddlewareInterface
{
    public function __construct(private string $role) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        // Set earlier by an authentication middleware.
        $roles = $request->getAttribute('roles', []);
        if (!in_array($this->role, $roles, true)) {
            throw new HttpForbiddenException($request, "This requires the {$this->role} role.");
        }

        return $handler->handle($request->withAttribute('role', $this->role));
    }
}
```

* Pass information to later middleware and controllers with `$request->withAttribute()`; never through a static
  or global, because the worker serves other requests afterwards.
* Refuse a request by throwing a Slim HTTP exception, so that the Error middleware formats it.
* Read configuration with `Kipchak\Driver\Config\Config::get('kipchak.<name>')` and services with drivers'
  `get()` methods, inside `process()` or in the constructor.
* To make it global, add it in `middlewares/middlewares.php` between the two `Error::initialise($app)` lines:
  `$app->add(new RequireRole('admin'));`
* For a reusable package, add a class implementing `Kipchak\Core\Interfaces\Middleware`, whose
  `initialise(App $app)` reads the package's configuration and calls `$app->add(...)` when it is enabled:

  ```php
  final class Maintenance implements Interfaces\Middleware
  {
      public static function initialise(App $app): void
      {
          $config = Config::get('kipchak.maintenance');
          if (!empty($config) && $config['enabled']) {
              $app->add(new Handlers\MaintenanceHandler($app->getContainer(), $config));
          }
      }
  }
  ```

* A middleware that reads the request body must read it once and pass the same content on (see
  `worker-mode.md`).
