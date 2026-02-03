# -----------------------------
# Stage 0: PHP + Apache + Composer
# -----------------------------
FROM php:7.4-apache AS base

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install zip pdo pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html/core

# Copy only composer files first to leverage Docker cache
COPY core/composer.json core/composer.lock* ./

# Ignore security advisories globally
RUN composer config --global audit.ignore all

# Install dependencies without dev packages
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs --no-scripts

# Copy the rest of the Laravel project
COPY core/ ./

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/core \
    && chmod -R 755 /var/www/html/core/storage

# Expose Apache port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
