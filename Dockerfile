FROM php:7.4-apache

# Enable Apache rewrite
RUN a2enmod rewrite

# System deps
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App root
WORKDIR /var/www/html

# Copy project
COPY . .

# Install PHP dependencies (composer.json is in root)
RUN composer install --no-dev --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
