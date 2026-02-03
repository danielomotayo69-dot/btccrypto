# Stage 0: PHP + Apache
FROM php:7.4-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install PHP extensions
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

# Set working directory
WORKDIR /var/www/html/core

# Copy Composer files
COPY core/composer.json core/composer.lock* ./

# Ignore security advisories and install dependencies
RUN composer config --global audit.ignore all
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs --no-scripts

# Copy the rest of the Laravel project
COPY core/ .

# Set permissions
RUN chown -R www-data:www-data /var/www/html/core \
    && chmod -R 755 /var/www/html/core/storage /var/www/html/core/bootstrap/cache

# Expose port 80
EXPOSE 80

# Set the DocumentRoot to Laravel's public folder
ENV APACHE_DOCUMENT_ROOT=/var/www/html/core/public

# Update Apache config for Laravel
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Start Apache
CMD ["apache2-foreground"]
