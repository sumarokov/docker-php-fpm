FROM php:7-fpm

MAINTAINER Roman Bulgakov
LABEL version=1.1

WORKDIR /root
RUN buildDeps='git libicu-dev libmcrypt-dev libfreetype6-dev libjpeg-dev libjpeg62-turbo-dev zlib1g-dev libxml2-dev libpq-dev libonig-dev libkrb5-dev libc-client-dev' && \
	set -eux && \
	apt-get update && \
	apt-get -y install \
		g++ \
		zip \
		libzip-dev \
		libzip4 \
		libicu-dev \
		libmcrypt4 \
		libfreetype6 \
		libjpeg62-turbo \
		libpng-dev \
		libmemcached-dev \
		zlib1g \
		libxml2 \
		mariadb-client \
		openssh-client \
		msmtp \
		postgresql \
		postgresql-contrib \
		$buildDeps \
		--no-install-recommends && \
	docker-php-ext-configure gd --with-freetype --with-jpeg && \
	docker-php-ext-configure bcmath --enable-bcmath && \
	docker-php-ext-configure pcntl --enable-pcntl && \
	docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
	PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
	docker-php-ext-install gd \
		intl \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		mbstring \
		zip \
		bcmath \
		pcntl \
		soap \
		sockets \
		mysqli \
		pgsql \
		opcache \
		imap && \
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
	pecl install apcu && \
	pecl install mcrypt && \
	docker-php-ext-enable mcrypt && \
	pecl install rar && \
	docker-php-ext-enable rar && \
	# clean the mess
	apt-get clean && \
	apt-get purge -y --auto-remove $buildDeps && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Configuration
COPY ./container-files/custom-php.ini /usr/local/etc/php/conf.d/

#opcache
ENV OPCACHE_MAX_ACCELERATED_FILES 4000
ENV OPCACHE_REVALIDATE_FREQ 60
ENV OPCACHE_MEMORY_CONSUMPTION 128
ENV OPCAHCE_INTERNED_STRINGS_BUFFER 8
ENV OPCAHCE_FAST_SHUTDOWN 1
ENV OPCACHE_SAVE_COMMENTS 0

RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.revalidate_freq=${OPCACHE_REVALIDATE_FREQ}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.memory_consumption=${OPCACHE_MEMORY_CONSUMPTION}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.max_accelerated_files=${OPCACHE_MAX_ACCELERATED_FILES}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.interned_strings_buffer=${OPCAHCE_INTERNED_STRINGS_BUFFER}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.fast_shutdown=${OPCAHCE_FAST_SHUTDOWN}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
	&& echo "opcache.save_comments=${OPCACHE_SAVE_COMMENTS}" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini