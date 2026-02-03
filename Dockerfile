FROM php:7.4-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html/core

# Copy composer files
COPY core/composer.json core/composer.lock* ./

# Disable Composer security advisory blocking
RUN composer config --global audit.ignore all
RUN composer config --global audit.block-insecure false

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs --no-scripts

# Copy the rest of your project
COPY core ./
