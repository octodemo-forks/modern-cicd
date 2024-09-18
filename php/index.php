<?php

require_once __DIR__ . '/vendor/autoload.php';

use Prometheus\CollectorRegistry;
use Prometheus\Storage\InMemory;
use Prometheus\RenderTextFormat;

$registry = new CollectorRegistry(new InMemory());

// Define some metrics (e.g., request count)
$counter = $registry->getOrRegisterCounter('php_app', 'requests_total', 'Total number of requests', ['status']);
$counter->incBy(1, ['200']); // Increment the counter for a 200 response code

// Expose metrics at /metrics
if ($_SERVER['REQUEST_URI'] == '/metrics') {
    header('Content-Type: text/plain');
    $renderer = new RenderTextFormat();
    echo $renderer->render($registry->getMetricFamilySamples());
    exit();
}

use Storefront\Controllers\ProductController;

// Create a ProductController instance
$productController = new ProductController();
$productController->showProduct();
