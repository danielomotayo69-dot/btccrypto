# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install PHP extensions needed by Laravel
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

# Set Apache document root to Laravel public folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html/core/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html/core

# Copy composer.json and composer.lock for caching
COPY core/composer.json core/composer.lock* ./

# Configure Composer to ignore advisory security blocks
RUN composer config --global audit.ignore all && \
    composer config --global audit.block-insecure false

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the project into the container
COPY . /var/www/html/

# Fix storage and bootstrap/cache permissions
RUN chown -R www-data:www-data /var/www/html/core/storage /var/www/html/core/bootstrap/cache && \
    chmod -R 775 /var/www/html/core/storage /var/www/html/core/bootstrap/cache

# Expose HTTP port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
