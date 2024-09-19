<?php

require_once __DIR__ . '/vendor/autoload.php';

use Prometheus\CollectorRegistry;
use Prometheus\Storage\InMemory;
use Prometheus\RenderTextFormat;
use Storefront\Controllers\ProductController;

$registry = new CollectorRegistry(new InMemory());

// Define some metrics (e.g., request count)
$counter = $registry->getOrRegisterCounter('php_app', 'requests_total', 'Total number of requests', ['status']);
$counter->incBy(1, ['200']); // Increment the counter for a 200 response code

// Expose metrics at /metrics
if ($_SERVER['REQUEST_URI'] === '/metrics') {
  $renderer = new RenderTextFormat();
  header('Content-Type: ' . RenderTextFormat::MIME_TYPE);
  echo $renderer->render($registry->getMetricFamilySamples());
  exit();
} else {
  // Create a ProductController instance
  $productController = new ProductController();
  $productController->showProduct();
}