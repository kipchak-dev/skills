# Endpoints: a complete resource

This builds `GET /v1/orders`, `GET /v1/orders/{id}` and `POST /v1/orders` in the style of the starter project's
`/v1/sultans` resource. Replace the model's array with a driver (usually Doctrine; see `drivers.md`) when the data
lives in a database.

## 1. DTO: `api/DataTransferObjects/v1/Order.php`

```php
<?php

declare(strict_types=1);

namespace Api\DataTransferObjects\v1;

use OpenApi\Attributes as OA;

/**
 * The same class describes the response and the request body. Fields the server sets are readOnly, so the
 * OpenAPI document leaves them out of request bodies.
 */
#[OA\Schema(schema: 'Order', description: 'An order placed by a customer.', required: ['reference', 'total'])]
final readonly class Order
{
    public function __construct(
        #[OA\Property(description: 'Identifier of the order, set by the server.', readOnly: true, example: 7)]
        public int $id,

        #[OA\Property(description: 'Customer reference for the order.', example: 'PO-2026-0042')]
        public string $reference,

        #[OA\Property(description: 'Total, in the order currency.', example: 149.5)]
        public float $total,

        #[OA\Property(description: 'Note from the customer, if any.', example: 'Deliver after 2pm.', nullable: true)]
        public ?string $note = null,
    ) {}
}
```

* One DTO per shape of data; nested shapes are DTOs of their own, referenced with `ref`.
* Arrays of DTOs: annotate the property with a PHPDoc `@var list<LineItem>` for Valinor and
  `#[OA\Property(type: 'array', items: new OA\Items(ref: '#/components/schemas/LineItem'))]` for OpenAPI.
* Dates: `DateTimeImmutable` properties with `format: 'date-time'` and an ISO 8601 example.
* Closed sets of values: a backed `enum`, which OpenAPI renders as an enum.

## 2. Model: `api/Models/Orders.php`

```php
<?php

declare(strict_types=1);

namespace Api\Models;

use Api\DataTransferObjects\v1\Order;
use CuyZ\Valinor\Mapper\MappingError;
use CuyZ\Valinor\Mapper\Source\Source;
use CuyZ\Valinor\Mapper\TreeMapper;
use CuyZ\Valinor\MapperBuilder;

final class Orders
{
    private const array ORDERS = [
        ['id' => 1, 'reference' => 'PO-2026-0001', 'total' => 20.0, 'note' => null],
        ['id' => 2, 'reference' => 'PO-2026-0002', 'total' => 149.5, 'note' => 'Deliver after 2pm.'],
    ];

    private TreeMapper $mapper;

    public function __construct()
    {
        $this->mapper = (new MapperBuilder())->mapper();
    }

    /**
     * @return list<Order>
     */
    public function all(): array
    {
        return array_map(fn (array $row): Order => $this->mapper->map(Order::class, Source::array($row)), self::ORDERS);
    }

    public function find(int $id): ?Order
    {
        foreach (self::ORDERS as $row) {
            if ($row['id'] === $id) {
                return $this->mapper->map(Order::class, Source::array($row));
            }
        }

        return null;
    }

    /**
     * Validates the request body by mapping it, with the fields the server sets, into the DTO.
     *
     * @param array<string, mixed> $input
     * @throws MappingError when the input does not match the DTO
     */
    public function create(array $input): Order
    {
        unset($input['id']);

        return $this->mapper->map(Order::class, Source::array(['id' => count(self::ORDERS) + 1] + $input));
    }
}
```

Valinor validates as it maps: a missing required field, a wrong type or an unexpected value throws
`CuyZ\Valinor\Mapper\MappingError`. Superfluous keys are rejected too; allow them with
`(new MapperBuilder())->allowSuperfluousKeys()->mapper()`.

## 3. Controller: `api/Controllers/v1/Orders.php`

```php
<?php

declare(strict_types=1);

namespace Api\Controllers\v1;

use Api\Models\Orders as OrdersModel;
use CuyZ\Valinor\Mapper\MappingError;
use JsonException;
use Kipchak\Core\Components\Controllers;
use Kipchak\Core\Components\Http;
use OpenApi\Attributes as OA;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Slim\Exception\HttpBadRequestException;
use Slim\Exception\HttpNotFoundException;

#[OA\Tag(name: 'Orders', description: 'Orders placed by customers.')]
final class Orders extends Controllers\Base
{
    #[OA\Get(
        path: '/v1/orders',
        operationId: 'listOrders',
        summary: 'List the orders',
        tags: ['Orders'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Every order.',
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: 'code', type: 'integer', example: 200),
                    new OA\Property(property: 'status', type: 'string', example: 'OK'),
                    new OA\Property(property: 'data', type: 'array', items: new OA\Items(ref: '#/components/schemas/Order')),
                ]),
            ),
        ],
    )]
    public function list(ServerRequestInterface $request, ResponseInterface $response, array $args): ResponseInterface
    {
        return Http\Response::json($response, (new OrdersModel())->all(), 200);
    }

    #[OA\Get(
        path: '/v1/orders/{id}',
        operationId: 'getOrder',
        summary: 'Get one order',
        tags: ['Orders'],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer', example: 2)),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'The order.',
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: 'code', type: 'integer', example: 200),
                    new OA\Property(property: 'status', type: 'string', example: 'OK'),
                    new OA\Property(property: 'data', ref: '#/components/schemas/Order'),
                ]),
            ),
            new OA\Response(response: 404, ref: '#/components/responses/NotFound'),
        ],
    )]
    public function get(ServerRequestInterface $request, ResponseInterface $response, array $args): ResponseInterface
    {
        $order = (new OrdersModel())->find((int) $args['id']);
        if ($order === null) {
            throw new HttpNotFoundException($request, "No order has the ID {$args['id']}.");
        }

        return Http\Response::json($response, $order, 200);
    }

    #[OA\Post(
        path: '/v1/orders',
        operationId: 'createOrder',
        summary: 'Place an order',
        tags: ['Orders'],
        requestBody: new OA\RequestBody(required: true, content: new OA\JsonContent(ref: '#/components/schemas/Order')),
        responses: [
            new OA\Response(
                response: 201,
                description: 'The order, as created.',
                content: new OA\JsonContent(properties: [
                    new OA\Property(property: 'code', type: 'integer', example: 201),
                    new OA\Property(property: 'status', type: 'string', example: 'CREATED'),
                    new OA\Property(property: 'data', ref: '#/components/schemas/Order'),
                ]),
            ),
            new OA\Response(response: 400, description: 'The body is not valid JSON or does not match the Order schema.'),
        ],
    )]
    public function create(ServerRequestInterface $request, ResponseInterface $response, array $args): ResponseInterface
    {
        try {
            // Read the body once; see worker-mode.md.
            $input = json_decode((string) $request->getBody(), true, flags: JSON_THROW_ON_ERROR);
            if (!is_array($input)) {
                throw new HttpBadRequestException($request, 'The body must be a JSON object.');
            }
            $order = (new OrdersModel())->create($input);
        } catch (JsonException) {
            throw new HttpBadRequestException($request, 'The body is not valid JSON.');
        } catch (MappingError $error) {
            $problems = array_map(static fn ($message): string => (string) $message, iterator_to_array($error->messages()->errors()));
            throw new HttpBadRequestException($request, 'The order is not valid: ' . implode(' ', $problems));
        }

        return Http\Response::json($response, $order, 201);
    }
}
```

* Path parameters arrive as strings in `$args`; cast them, and constrain them in the route pattern.
* Query parameters: `$request->getQueryParams()['page'] ?? '1'`, validated and cast, and documented as
  `new OA\Parameter(name: 'page', in: 'query', ...)`.
* Headers: `$request->getHeaderLine('X-Request-Id')`.
* Values set by middleware (an authenticated consumer, for example): `$request->getAttribute('name')`.
* A response that is not JSON: write to `$response->getBody()` and return it with its `Content-Type`.
* Shared responses (such as `NotFound`) are declared once in `api/OpenApi/Definition.php` with
  `#[OA\Response(response: 'NotFound', ...)]` and referenced as `#/components/responses/NotFound`.

## 4. Route: `routes/v1/orders.php`

```php
<?php

use Api\Controllers;
use Slim\Routing\RouteCollectorProxy;

/**
 * @var \Kipchak\Core\Components\App $app
 */
$app->group('/v1', function (RouteCollectorProxy $group) {
    $group->get('/orders', [Controllers\v1\Orders::class, 'list']);
    $group->get('/orders/{id:[0-9]+}', [Controllers\v1\Orders::class, 'get']);
    $group->post('/orders', [Controllers\v1\Orders::class, 'create']);
});
```

Every file in `routes/` is loaded, in no guaranteed order, so a route file must not depend on another. Several
files may each declare a `/v1` group. The OpenAPI path uses `{id}` where the route uses `{id:[0-9]+}`.

## 5. Test: `tests/OrdersTest.php`

The starter's `tests/ApiTestCase.php` boots the API once per process and has `request($method, $path)` and
`json($response)` helpers. To send a body, add a variant that writes it:

```php
protected function send(string $method, string $path, string $body): ResponseInterface
{
    self::$app ??= Api::boot();
    $request = new ServerRequestFactory()->createServerRequest($method, $path)
        ->withHeader('Accept', 'application/json')
        ->withHeader('Content-Type', 'application/json')
        ->withBody(new StreamFactory()->createStream($body));

    return self::$app->handle($request);
}
```

(`Slim\Psr7\Factory\StreamFactory`.) Then:

```php
<?php

declare(strict_types=1);

namespace Tests;

final class OrdersTest extends ApiTestCase
{
    public function testGetsOneOrder(): void
    {
        $response = $this->request('GET', '/v1/orders/2');

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('PO-2026-0002', $this->json($response)['data']['reference']);
    }

    public function testAnUnknownOrderIsNotFound(): void
    {
        $response = $this->request('GET', '/v1/orders/99');

        self::assertSame(404, $response->getStatusCode());
        self::assertSame('RESOURCE_NOT_FOUND', $this->json($response)['status']);
    }

    public function testPlacesAnOrder(): void
    {
        $response = $this->send('POST', '/v1/orders', '{"reference": "PO-2026-0003", "total": 12.5}');

        self::assertSame(201, $response->getStatusCode());
        self::assertSame(3, $this->json($response)['data']['id']);
    }

    public function testRefusesAnInvalidOrder(): void
    {
        $response = $this->send('POST', '/v1/orders', '{"reference": "PO-2026-0003"}');

        self::assertSame(400, $response->getStatusCode());
    }
}
```

Because the application boots once per test process, tests must not depend on state a previous test left in a
static. After adding an endpoint, run `composer test` and `composer openapi`.
