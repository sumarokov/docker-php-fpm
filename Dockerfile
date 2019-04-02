FROM php:7-fpm

MAINTAINER Roman Bulgakov
LABEL version=1.1

WORKDIR /root
RUN buildDeps='git libicu-dev libmcrypt-dev libfreetype6-dev libjpeg-dev libjpeg62-turbo-dev zlib1g-dev libxml2-dev' && \
    set -x && \
    apt-get update && \
    apt-get -y install \
            g++ \
            zip \
            libzip-dev \
			libicu-dev \
			libmcrypt4 \
			libfreetype6 \
			libjpeg62-turbo \
			libpng-dev \
			libmemcached-dev \
			zlib1g \
			libxml2 \
            mysql-client \
            openssh-client \
            $buildDeps \
            --no-install-recommends && \
    # Install PHP extensions required for Yii 2.0 Framework
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-configure zip --with-libzip && \
    docker-php-ext-install gd \
                           intl \
                           pdo_mysql \
                           mbstring \
                           zip \
                           bcmath \
                           soap && \
    curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/master.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    # Install PECL extensions
    # see http://stackoverflow.com/a/8154466/291573) for usage of `printf`
    printf "\n" | pecl install apcu && \
    pecl install mcrypt-1.0.2 && \
    docker-php-ext-enable mcrypt && \
    # clean the mess
    apt-get clean && \
    apt-get purge -y --auto-remove $buildDeps && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Configuration
COPY ./container-files/custom-php.ini /usr/local/etc/php/conf.d/