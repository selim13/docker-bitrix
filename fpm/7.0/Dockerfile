FROM php:7.0-fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libedit-dev \
    libcurl3-gnutls-dev \
    libxml2-dev \
    curl \
    msmtp \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mcrypt mbstring mysqli readline curl opcache zip soap json


# Install Composer
ENV COMPOSER_HOME /composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_VERSION 1.4.1

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} \
    && rm -rf /tmp/composer-setup.php

# Memcache from PECL does't build with php 7.0 anymore, so manually build it's patched version
RUN curl -SL https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.tar.gz -o /tmp/memcache.tar.gz \
    && tar xzf /tmp/memcache.tar.gz -C /tmp \
    && mkdir -p /usr/src/php/ext \
    && mv /tmp/pecl-memcache-NON_BLOCKING_IO_php7 /usr/src/php/ext/memcache \
    && echo 'memcache' >> /usr/src/php-available-exts \
    && docker-php-ext-install memcache \
    && rm -rf /usr/src/php/ext/memcache

RUN usermod -u 1000 www-data

COPY php/conf.d/* /usr/local/etc/php/conf.d/
COPY php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /tmp/php_sessions/www /tmp/php_upload/www /tmp/opcache /var/log/php /var/log/msmtp \
    && chown -R www-data:www-data /tmp/php_sessions /tmp/php_upload /tmp/opcache /var/log/msmtp \
    && chown www-data:www-data /var/www/html