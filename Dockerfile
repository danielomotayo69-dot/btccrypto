# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache rewrite
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

# Set Apache document root to Laravel public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/core/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html/core

# Copy composer files first for caching
COPY core/composer.json core/composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the project
COPY . /var/www/html/

# Fix permissions
RUN chown -R www-data:www-data /var/www/html/core/storage /var/www/html/core/bootstrap/cache \
    && chmod -R 775 /var/www/html/core/storage /var/www/html/core/bootstrap/cache

# Expose HTTP port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
