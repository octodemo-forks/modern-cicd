<?php

require_once __DIR__ . '/vendor/autoload.php';

use Storefront\Controllers\ProductController;

// Create a ProductController instance
$productController = new ProductController();
$productController->showProduct();