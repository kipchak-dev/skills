# Drivers

A driver connects the API to one external service: a database, cache, queue, object store, AI model and so on.
Each is a Composer package, configured by a file in `config/` and initialised in `drivers/drivers.php`. The list of
drivers is in `packages.md`; each has a documentation page at `https://kipchak.dev/docs/driver-<name>`.

## Using a driver

1. Install it: `composer require kipchak/driver-doctrine`.
2. Add its configuration file to `config/`, named as its documentation page says (`kipchak.doctrine.php`). Read
   secrets and hosts from the environment with `env()`:

   ```php
   <?php

   use function Kipchak\Core\env;

   return [
       'dbal' => [
           'enabled' => true,
           'connections' => [
               'primary' => [
                   'dbname' => env('DB_NAME', 'api'),
                   'user' => env('DB_USER', 'api'),
                   'password' => env('DB_PASSWORD', 'api'),
                   'host' => env('DB_HOST', 'mysql'),
                   'driver' => 'pdo_mysql',
               ],
           ],
       ],
       'orm' => [
           'enabled' => true,
           'entity_managers' => [
               'primary' => [
                   'dev_mode' => (bool) env('DEBUG', true),
                   'metadata_dirs' => [realpath(__DIR__ . '/../api/Entities/Doctrine/Primary')],
                   'connection' => 'primary',
               ],
           ],
       ],
   ];
   ```

3. Initialise it in `drivers/drivers.php`, after Config and Logger, which every other driver relies on:

   ```php
   use Kipchak\Driver\Config\Config;
   use Kipchak\Driver\Doctrine\Doctrine;
   use Kipchak\Driver\Logger\Logger;

   Config::initialise($container);
   Logger::initialise($container);
   Doctrine::initialise($container);
   ```

4. Use it through its static `get()`, with the name of a connection, pool or client from its configuration:

   ```php
   $em = Doctrine::get('entitymanager.primary');   // Doctrine ORM EntityManager
   $db = Doctrine::get('dbal.primary');            // Doctrine DBAL Connection
   $cache = Memcached::get('cache');               // Symfony cache adapter (PSR-6 and contracts)
   $http = Http::get();                            // HTTP client; Http::get('name') for a configured one
   $logger = Logger::get();                        // Monolog
   ```

Call `get()` where the service is used, inside a model or controller method, not in a static initialiser: drivers
register lazy factories, and the connection is created on first use.

## Relational databases: the Doctrine driver

* Entities live in `api/Entities/Doctrine/<Connection>/`, with Doctrine's attribute mapping, and are listed in the
  entity manager's `metadata_dirs`.
* Models use the entity manager or DBAL and return DTOs, never entities: map an entity or a row into the DTO.
* Migrations are plain SQL files in `migrations/database/`, with the up statements first and the down statements
  after a `-- Down` line, applied with `php vendor/bin/doctrine migrations:up --em=primary`.
* In worker mode one entity manager serves many requests. Clear it at the start of each request
  (`$em->clear()`) and replace a lost connection, as the commented lines in the starter's `html/index.php` show;
  uncomment them for each entity manager when the project uses Doctrine.

## Writing a driver

Write a driver when the API needs a service no Kipchak driver covers, or wraps an internal service the team uses in
several APIs. A driver implements `Kipchak\Core\Interfaces\Driver`:

```php
public static function initialise(ContainerInterface $container, ?string $configFileName = null);
public static function set();
public static function get(?string $configKey = null);
```

The established pattern, from the Memcached driver:

```php
<?php

declare(strict_types=1);

namespace Acme\Driver\Inventory;

use Kipchak\Core\Interfaces;
use Kipchak\Driver\Config\Config;
use Psr\Container\ContainerInterface;

final class Inventory implements Interfaces\Driver
{
    private static ?ContainerInterface $container = null;

    public static function initialise(ContainerInterface $container, ?string $configFileName = null): void
    {
        self::$container = $container;
        self::set($configFileName);
    }

    /**
     * Registers one lazy factory per configured connection. Nothing connects until get() is first called.
     */
    public static function set(?string $configFileName = null): void
    {
        $config = Config::get($configFileName ?? 'kipchak.inventory');
        if (empty($config)) {
            return;
        }

        foreach ($config['connections'] ?? [] as $name => $connection) {
            self::$container->set(
                'drivers.inventory.' . $name,
                static fn (ContainerInterface $c): Client => new Client($connection['url'], $connection['token']),
            );
        }
    }

    public static function get(?string $configKey = null): Client
    {
        return self::$container->get('drivers.inventory.' . ($configKey ?? 'default'));
    }
}
```

* Container keys follow `drivers.<category>.<driver>.<connection>`.
* The configuration file is `config/kipchak.<driver>.php`, and `$configFileName` lets a project load a second one.
* `Config::get()` returns an array (empty when the file does not exist); it has no `->get()` method.
* Register factories, not instances, so that nothing connects at boot and a failed connection can be replaced.
* A client that keeps a connection open must survive the service restarting: reconnect on the next call after a
  failure, rather than failing every later request on that worker (see `worker-mode.md`).
* A driver for the team's own use can live in the project (`api/Drivers/`, autoloaded) or in its own Composer
  package. Initialise it in `drivers/drivers.php` like any other.
