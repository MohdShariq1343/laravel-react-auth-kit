
#!/bin/bash

set -e

cd /var/www/html

echo "Preparing Laravel..."

mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache

echo "Clearing configuration cache..."

php artisan config:clear

echo "Checking PostgreSQL connection..."

php artisan db:show

echo "Running migrations..."

php artisan migrate --force

if [ ! -L public/storage ]; then
    php artisan storage:link
fi

echo "Caching configuration..."

php artisan config:cache
php artisan view:cache

chown -R www-data:www-data storage bootstrap/cache

echo "Checking Nginx..."

nginx -t

php-fpm -D

echo "Starting Nginx..."

exec nginx -g "daemon off;"
