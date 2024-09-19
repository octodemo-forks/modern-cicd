<?php

require_once __DIR__ . '/vendor/autoload.php';

use Prometheus\CollectorRegistry;
// use Prometheus\Storage\InMemory;
use Prometheus\RenderTextFormat;
use Storefront\Controllers\ProductController;

$redis = new Redis();
$redis->connect('redis-master', 6379); // Redis service from Helm

// Initialize the counter if it doesn't exist
if (!$redis->exists('php_app_requests_total')) {
    $redis->set('php_app_requests_total', 0);
}

// Increment the counter
$redis->incr('php_app_requests_total');

// $registry = new CollectorRegistry(new InMemory());

// Define some metrics (e.g., request count)
// $counter = $registry->getOrRegisterCounter('php_app', 'requests_total', 'Total number of requests', ['status']);
// $counter->incBy(1, ['200']); // Increment the counter for a 200 response code

// Expose metrics at /metrics
if ($_SERVER['REQUEST_URI'] === '/metrics') {
  $renderer = new RenderTextFormat();
  header('Content-Type: ' . RenderTextFormat::MIME_TYPE);

  $requests_total = $redis->get('php_app_requests_total');
  echo "# HELP php_app_requests_total Total number of requests\n";
  echo "# TYPE php_app_requests_total counter\n";
  echo "php_app_requests_total " . $requests_total . "\n";
  // echo $renderer->render($registry->getMetricFamilySamples());
  exit();
} else {
  // Create a ProductController instance
  $productController = new ProductController();
  $productController->showProduct();
}