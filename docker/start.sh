
#!/bin/bash

set -e

cd /var/www/html

echo "Preparing Laravel..."

# Ensure required directories exist
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Set permissions
chown -R www-data:www-data storage bootstrap/cache

# Clear old cached configuration
php artisan optimize:clear

# Cache production configuration
php artisan config:cache
php artisan view:cache

# Run database migrations
php artisan migrate --force

echo "Starting PHP-FPM..."

php-fpm -D

echo "Starting Nginx..."

exec nginx -g "daemon off;"
