<?php

require_once __DIR__ . '/vendor/autoload.php';

use Prometheus\CollectorRegistry;
use Prometheus\Storage\Redis as PrometheusRedis;
use Prometheus\RenderTextFormat;
use Storefront\Controllers\ProductController;

// Configure Redis connection for Prometheus metrics
$redisAdapter = new PrometheusRedis([
  'host' => 'sample-php-app-redis-master',  // Use the Redis master service or IP address
  'port' => 6379,  // Redis port
]);

// Initialize the registry with Redis storage
$registry = new CollectorRegistry($redisAdapter);


// Metrics initialization
$totalRequestsCounter = $registry->getOrRegisterCounter('php_app', 'requests_total', 'Total number of requests');
$errorsCounter = $registry->getOrRegisterCounter('php_app', 'errors_total', 'Total number of errors');
$memoryUsageGauge = $registry->getOrRegisterGauge('php_app', 'memory_usage_bytes', 'Current memory usage in bytes');
$requestDurationHistogram = $registry->getOrRegisterHistogram('php_app', 'request_duration_seconds', 'Request duration in seconds');
$activeSessionsGauge = $registry->getOrRegisterGauge('php_app', 'active_sessions', 'Number of active sessions');

// Increment the total requests counter
$totalRequestsCounter->inc();

// Measure request duration with a histogram
$memoryUsageGauge->set(memory_get_usage());

// Expose metrics at /metrics
if ($_SERVER['REQUEST_URI'] === '/metrics') {
  $renderer = new RenderTextFormat();
  header('Content-Type: ' . RenderTextFormat::MIME_TYPE);
  echo $renderer->render($registry->getMetricFamilySamples());
  exit();
} else {
  $startTime = microtime(true);

  // Create a ProductController instance
  $productController = new ProductController();
  $productController->showProduct();

  $endTime = microtime(true);
  $requestDuration = $endTime - $startTime;
  $requestDurationHistogram->observe($requestDuration);
}
