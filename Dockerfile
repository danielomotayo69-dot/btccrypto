# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install PHP extensions required by Laravel
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

# Set working directory to /core
WORKDIR /var/www/html/core

# Copy composer files into /core
COPY core/composer.json core/composer.lock* ./

# Optional: ignore security advisories (only if you choose not to upgrade Laravel)
# RUN composer config --global security-checker ignore

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the project into /var/www/html
COPY . /var/www/html/

# Fix permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# Expose HTTP port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

