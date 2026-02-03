# Use PHP 7.4 with Apache
FROM php:7.4-apache

# Enable Apache rewrite
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

# Disable Composer security blocking (Laravel 7 is EOL)
RUN composer config --global audit.ignore "*"
RUN composer config --global audit.block-insecure false

# Set working directory to Laravel core
WORKDIR /var/www/html/core

# Copy composer files only
COPY core/composer.json core/composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy the rest of the project
COPY . /var/www/html/

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
