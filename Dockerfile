# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory to Laravel project folder
WORKDIR /var/www/html/core

# Copy composer files first for dependency install
COPY core/composer.json core/composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the project
COPY . /var/www/html/

# Fix permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
