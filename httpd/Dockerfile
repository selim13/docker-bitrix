FROM php:7.1-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libedit-dev \
    libcurl3-gnutls-dev \
    libxml2-dev \
    libpspell-dev \
    curl \
    msmtp \
    ssl-cert \
    && rm -rf /var/lib/apt/lists/* \
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) curl gd json mcrypt mbstring mysqli pspell readline opcache sockets soap zip  \
    && pecl install xdebug-2.7.0 apcu \
    && docker-php-ext-enable xdebug apcu

# Memcache from PECL does't build with php 7.1 anymore, so manually build it's patched version
ENV MEMCACHE_VERSION 4.0.3
RUN curl -SL https://github.com/websupport-sk/pecl-memcache/archive/${MEMCACHE_VERSION}.tar.gz -o /tmp/memcache.tar.gz \
    && tar xzf /tmp/memcache.tar.gz -C /tmp \
    && mkdir -p /usr/src/php/ext \
    && mv /tmp/pecl-memcache-${MEMCACHE_VERSION} /usr/src/php/ext/memcache \
    && echo 'memcache' >> /usr/src/php-available-exts \
    && docker-php-ext-install memcache \
    && rm -rf /usr/src/php/ext/memcache /tmp/memcache.tar.gz

# Install Composer
ENV COMPOSER_HOME /composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_VERSION 1.8.4

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
    && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} \
    && rm -rf /tmp/composer-setup.php


RUN usermod -u 1000 www-data

COPY php/* "$PHP_INI_DIR/conf.d/"
COPY apache/virtual_host.tmpl.conf apache/virtual_host-ssl.tmpl.conf $APACHE_CONFDIR/
COPY apache/default.conf $APACHE_CONFDIR/sites-available/000-default.conf

RUN a2enmod expires rewrite \
    && a2dismod -f negotiation \
    && sed -ri -e 's!^(\s*KeepAlive)\s+\S+!\1 Off!g' $APACHE_CONFDIR/apache2.conf 

ENV WWWDATA_DIRS \
    /tmp/php_sessions/default \
    /tmp/php_upload/default \
    /tmp/opcache \
    /var/log/php \
    /var/log/msmtp \
    $COMPOSER_HOME    

RUN mkdir -p $WWWDATA_DIRS /home/bitrix/www /home/bitrix/ext_www \
    && chown -R www-data:www-data $WWWDATA_DIRS \
    && chown www-data:www-data /home/bitrix/www /home/bitrix/ext_www

RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY index.php /home/bitrix/www/

ENV BX_HOSTS= \
    BX_USE_SSL= \
    BX_REMOTEIP= \
    BX_KEEPALIVETIMEOUT= \
    BX_STARTSERVERS=5 \
    BX_MINSPARESERVERS=5 \
    BX_MAXSPARESERVERS=10 \
    BX_MAXREQUESTWORKERS=150 \
    BX_MAXREQUESTSPERCHILD=0

COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh
CMD ["start.sh"]