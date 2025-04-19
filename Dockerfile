# ベースイメージ（Apache付きPHP）
FROM php:8.2-apache

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Composerをインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Laravelアプリをコピー
COPY . /var/www/html

# Apacheのドキュメントルートを Laravelのpublicに変更
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# mod_rewriteを有効に
RUN a2enmod rewrite

# 作業ディレクトリを設定
WORKDIR /var/www/html

# .envを仮に作っておく（Render側で環境変数からAPP_KEYなどを設定する想定）
RUN cp .env.example .env

# 権限を調整（任意）
RUN chown -R www-data:www-data /var/www/html

# ポートをExpose（Renderは自動認識する。）
EXPOSE 80


# スタートコマンド（Apache起動）
CMD ["apache2-foreground"]
