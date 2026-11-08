# ==========================================
# Stage 1: Build React frontend using Vite
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

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    unzip \
    zip \
    libpq-dev \
    libsqlite3-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

# Install PHP extensions
# Use -j2 to reduce memory usage during Render builds
RUN docker-php-ext-install -j2 \
    pdo_pgsql \
    pdo_mysql \
    pdo_sqlite \
    sqlite3 \
    mbstring \
    bcmath \
    gd \
    zip \
    intl \
    exif \
    pcntl \
    opcache \
    curl \
    xml

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel source code
COPY . .

# Install Laravel production dependencies
RUN composer install \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader \
    --no-interaction

# Copy built React/Vite assets
COPY --from=frontend /app/public/build ./public/build

# Confirm Vite manifest exists
RUN test -f public/build/manifest.json

# Create required Laravel directories
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

# Configure Nginx
RUN rm -f /etc/nginx/sites-enabled/default

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy startup script
COPY docker/start.sh /start.sh

RUN chmod +x /start.sh

# Render default web service port
EXPOSE 10000

# Start application
CMD ["/start.sh"]