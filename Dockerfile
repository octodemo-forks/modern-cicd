# Use an official PHP runtime as a parent image
FROM php:8.2-apache

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY /php /var/www/html
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Install dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    php-apcu \
    && docker-php-ext-install zip pdo_mysql \
    # Enable Apache mod_rewrite (for URL rewriting if needed)
    && a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install PHP dependencies with Composer
RUN composer install --no-interaction --no-scripts --prefer-dist

# Give ownership to Apache user (www-data)
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start the Apache service
CMD ["apache2-foreground"]
