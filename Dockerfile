FROM php:8.1-apache

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Composerをインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravelアプリをコピー（←これより前にcomposer installしても意味なし）
COPY . /var/www/html

# Composerで依存パッケージをインストール（vendor/ ができる）
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# LaravelのAPP_KEYを生成（.envがないと失敗するので先にコピーしておく）
RUN cp .env.example .env && php artisan key:generate

# Apacheの設定をLaravelに最適化
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# 作業ディレクトリ
WORKDIR /var/www/html

# 権限調整（お好みで）
RUN chown -R www-data:www-data /var/www/html

CMD ["apache2-foreground"]
