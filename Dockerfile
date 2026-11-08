
# ==========================================
# Stage 1: Build React frontend
# ==========================================
FROM node:22-bookworm-slim AS frontend

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build


# ==========================================
# Stage 2: Laravel PHP 8.2 + Nginx
# ==========================================
FROM php:8.2-fpm-bookworm

# Install required system libraries
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    unzip \
    libpq-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure GD
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# Install PostgreSQL extension separately
RUN docker-php-ext-install pdo_pgsql

# Install other Laravel extensions
RUN docker-php-ext-install -j2 \
    mbstring \
    bcmath \
    exif \
    pcntl \
    opcache

# Install image, archive and internationalization extensions
RUN docker-php-ext-install -j2 \
    gd \
    zip \
    intl

# Install HTTP and XML extensions
RUN docker-php-ext-install -j2 \
    curl \
    xml

# Working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel application
COPY . .

# Install production dependencies
RUN composer install \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader \
    --no-interaction

# Copy React build
COPY --from=frontend /app/public/build ./public/build

# Check Vite manifest
RUN test -f public/build/manifest.json

# Create Laravel directories
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Configure Nginx
RUN rm -f /etc/nginx/sites-enabled/default

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Startup script
COPY docker/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 10000

CMD ["/start.sh"]
