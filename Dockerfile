FROM php:7.4-fpm-alpine

RUN apk add libzip-dev
RUN docker-php-ext-install zip

RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev
RUN docker-php-ext-configure gd \
    --with-gd \
    --with-libzip=/usr/local/lib/libzip-1.5.2/bin \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)
RUN docker-php-ext-install -j${NPROC} gd
RUN apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"
RUN pecl install imagick-3.4.3
RUN docker-php-ext-enable imagick
RUN apk add --no-cache --virtual .imagick-runtime-deps imagemagick
RUN apk del .phpize-deps

RUN docker-php-ext-install pcntl pdo_mysql exif sockets

RUN apk add autoconf g++ make openssl-dev
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb
