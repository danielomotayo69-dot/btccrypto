# -------------------------------
# PHP 7.4 + Composer + Laravel 7.30 Dockerfile
# -------------------------------

# Use PHP 7.4 FPM image
FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www/html/core

# -------------------------------
# Install system dependencies
# -------------------------------
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-install \
       pdo_mysql \
       mbstring \
       exif \
       pcntl \
       bcmath \
       gd \
       zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install Composer (v2 compatible with PHP 7.4)
# -------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -------------------------------
# Copy composer files
# -------------------------------
COPY core/composer.json core/composer.lock* ./

# -------------------------------
# Disable security advisory blocking for Laravel 7.30
# -------------------------------
RUN composer config --global audit.ignore all
RUN composer config --global audit.block-insecure false

# -------------------------------
# Install Laravel dependencies
# -------------------------------
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs --no-scripts

# -------------------------------
# Copy rest of the Laravel project
# -------------------------------
COPY core ./

# -------------------------------
# Set permissions (optional but recommended)
# -------------------------------
RUN chown -R www-data:www-data /var/www/html/core/storage /var/www/html/core/bootstrap/cache

# -------------------------------
# Expose HTTP port
# -------------------------------
EXPOSE 8000

# -------------------------------
# Start PHP built-in server
# -------------------------------
CMD php -S 0.0.0.0:8000 -t /var/www/html/core/public
