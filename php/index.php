<?php

require_once __DIR__ . '/vendor/autoload.php';

use Prometheus\CollectorRegistry;
use Prometheus\Storage\InMemory;
use Prometheus\RenderTextFormat;
use Storefront\Controllers\ProductController;

// $redis = new Redis();
// $redis->connect('sample-php-app-redis-master', 6379); // Redis service from Helm

$registry = new CollectorRegistry(new InMemory());

// Initialize the counter if it doesn't exist
// if (!$redis->exists('php_app_requests_total')) {
//     $redis->set('php_app_requests_total', 0);
// }

// Metrics initialization
$totalRequestsCounter = $registry->getOrRegisterCounter('php_app', 'requests_total', 'Total number of requests');
$errorsCounter = $registry->getOrRegisterCounter('php_app', 'errors_total', 'Total number of errors');
$memoryUsageGauge = $registry->getOrRegisterGauge('php_app', 'memory_usage_bytes', 'Current memory usage in bytes');
$requestDurationHistogram = $registry->getOrRegisterHistogram('php_app', 'request_duration_seconds', 'Request duration in seconds');
$activeSessionsGauge = $registry->getOrRegisterGauge('php_app', 'active_sessions', 'Number of active sessions');

// Increment the total requests counter
$totalRequestsCounter->inc();

// Measure request duration
$start = microtime(true);

// Simulate application logic
try {
    // Simulating session increment
    $activeSessionsGauge->inc();
    
    // Simulate application logic...
    if ($someErrorCondition) {
        throw new Exception('Error occurred!');
    }

    // Set memory usage
    $memoryUsageGauge->set(memory_get_usage());
} catch (Exception $e) {
    // Increment error counter on exception
    $errorsCounter->inc();
}

$end = microtime(true);
$requestDuration = $end - $start;
$requestDurationHistogram->observe($requestDuration);

// Increment the counter
// $redis->incr('php_app_requests_total');

// Expose metrics at /metrics
if ($_SERVER['REQUEST_URI'] === '/metrics') {
  $renderer = new RenderTextFormat();
  header('Content-Type: ' . RenderTextFormat::MIME_TYPE);

  // $requests_total = $redis->get('php_app_requests_total');
  // echo "# HELP php_app_requests_total Total number of requests\n";
  // echo "# TYPE php_app_requests_total counter\n";
  // echo "php_app_requests_total " . $requests_total . "\n";
  echo $renderer->render($registry->getMetricFamilySamples());
  exit();
} else {
  // Create a ProductController instance
  $productController = new ProductController();
  $productController->showProduct();
}