# Use an official PHP runtime as a parent image
FROM php:7.4-apache

# Copy the current directory contents into the container at /var/www/html
COPY /src/ /var/www/html/

# Expose port 80
EXPOSE 80

# Run Apache in the foreground
CMD ["apache2-foreground"]