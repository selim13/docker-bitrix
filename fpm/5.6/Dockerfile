FROM php:5.6-fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpng12-dev \
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

RUN pecl install memcache \
    && rm -rf /tmp/pear

RUN usermod -u 1000 www-data

COPY php/conf.d/* /usr/local/etc/php/conf.d/
COPY php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /tmp/php_sessions/www /tmp/php_upload/www \
    && chown -R www-data:www-data /tmp/php_sessions /tmp/php_upload \
    && chown www-data:www-data /var/www/html