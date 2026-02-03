# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install PHP extensions Laravel needs
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

# Set working directory inside the container
WORKDIR /var/www/html/core

# Copy composer files first for dependency installation
COPY core/composer.json core/composer.lock* ./

# Tell Composer to ignore security advisories (fixes blocked Laravel 7.30.7)
RUN composer config --global audit.ignore all

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy the rest of the Laravel project into /core
COPY core/ ./

# Set permissions for Laravel storage and cache
RUN chmod -R 775 storage bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose HTTP port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
