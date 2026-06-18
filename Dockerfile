FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    curl \
    git \
    unzip \
    libzip-dev \
    oniguruma-dev \
    nodejs \
    npm \
    && docker-php-ext-install \
    pdo_sqlite \
    mbstring \
    zip \
    bcmath \
    gd \
    intl

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN cp .env.example .env \
    && composer install --no-interaction --no-dev --optimize-autoloader \
    && npm ci \
    && npm run build \
    && touch database/database.sqlite \
    && php artisan key:generate --force \
    && php artisan storage:link \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache /var/www/database

USER www-data
