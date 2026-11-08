#!/bin/bash

set -e

cd /var/www/html

echo "================================="
echo "Starting Laravel application"
echo "================================="

# Create Laravel required directories
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Set permissions
chown -R www-data:www-data storage bootstrap/cache

# Clear old Laravel cached configuration
echo "Clearing Laravel cache..."

php artisan optimize:clear

# Check PostgreSQL connection
echo "Checking database connection..."

php artisan db:show

# Run migrations
echo "Running database migrations..."

php artisan migrate --force

# Create storage symbolic link
if [ ! -L public/storage ]; then
    php artisan storage:link
fi

# Cache Laravel configuration
echo "Caching Laravel configuration..."

php artisan config:cache

php artisan view:cache

# Set permissions again
chown -R www-data:www-data storage bootstrap/cache

# Check Nginx configuration
nginx -t

# Start PHP-FPM
php-fpm -D

# Start Nginx
echo "================================="
echo "Laravel application started"
echo "================================="

exec nginx -g "daemon off;"