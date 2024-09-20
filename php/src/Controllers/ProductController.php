<?php

namespace Storefront\Controllers;

use Storefront\Models\Product;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

class ProductController
{
    private $twig;

    public function __construct()
    {
        // Set up Twig
        $loader = new FilesystemLoader(__DIR__ . '/../../templates');
        $this->twig = new Environment($loader);
    }

    public function showProduct()
    {
        // Create a product instance (could be fetched from a database)
        $product = new Product("Sample Product", "This is a great product!", 18.99);

        // Render the product page
        echo $this->twig->render('product.html.twig', [
            'product' => [
                'name' => $product->getName(),
                'description' => $product->getDescription(),
                'price' => $product->getPrice()
            ]
        ]);
    }
}
