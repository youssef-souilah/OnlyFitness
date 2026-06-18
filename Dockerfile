FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    curl \
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
    && php artisan key:generate --force \
    && php artisan storage:link \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache \
    && rm .env \
    && mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
    && chmod -R 775 storage bootstrap/cache database \
    && chmod +x start.sh

EXPOSE 8080

CMD ["./start.sh"]
