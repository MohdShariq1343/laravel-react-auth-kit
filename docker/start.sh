#!/bin/bash

set -e

cd /var/www/html

echo "================================"
echo "Preparing Laravel..."
echo "================================"

# Create Laravel directories
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Permissions
chown -R www-data:www-data storage bootstrap/cache

# Clear configuration cache without clearing database cache
echo "Clearing configuration cache..."

php artisan config:clear

# Check PostgreSQL connection
echo "Checking PostgreSQL connection..."

php artisan db:show

# Run migrations
echo "Running database migrations..."

php artisan migrate --force

# Create storage link
if [ ! -L public/storage ]; then
    php artisan storage:link
fi

# Cache production configuration
echo "Caching Laravel configuration..."

php artisan config:cache

php artisan view:cache

# Permissions again
chown -R www-data:www-data storage bootstrap/cache

# Validate Nginx
nginx -t

# Start PHP-FPM
php-fpm -D

echo "Laravel is ready!"

# Start Nginx
exec nginx -g "daemon off;"