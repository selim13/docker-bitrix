FROM php:5.6-apache

#https://github.com/tests-always-included/mo

RUN sed -i "s/jessie main/jessie main contrib/" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends libpng12-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libmcrypt-dev \
        libedit-dev \
        libcurl3-gnutls-dev \
        libxml2-dev \
        libapache2-mod-geoip \
        geoip-database-contrib \
        curl \
        msmtp \
    && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mcrypt mbstring mysqli readline curl opcache zip soap json

RUN pecl install apcu-4.0.11 \
    && rm -rf /tmp/pear
COPY php5/conf.d/* /usr/local/etc/php/conf.d/
# COPY test.php /var/www/html

COPY apache2/mods-available/* /etc/apache2/mods-available/
COPY apache2/conf-available/* /etc/apache2/conf-available/
COPY apache2/sites-available/* /etc/apache2/sites-available/

RUN a2enmod rewrite remoteip geoip \
    && a2enconf keepalive

RUN usermod -u 1000 www-data

RUN mkdir -p /tmp/php_sessions/www /tmp/php_upload/www \
    && chown -R www-data:www-data /tmp/php_sessions /tmp/php_upload \
    && chown www-data:www-data /var/www/html

ENV BX_SITES=

COPY start.sh /usr/local/bin

#ENTRYPOINT ["start.sh"]
#CMD ["apache2-foreground"]
CMD ["start.sh"]