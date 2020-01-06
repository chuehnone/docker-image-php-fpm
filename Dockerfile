FROM php:7.3.9-fpm-alpine

RUN apk --no-cache --update add \
  vim \
  freetype-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libzip-dev \
  && docker-php-ext-install \
    bcmath \
    pdo_mysql \
    zip \
    opcache \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd \
  # Install php intl extension
  && apk --no-cache add icu-dev \
  && docker-php-ext-configure intl --enable-intl \
  && docker-php-ext-install intl \
  # Install php redis
  && apk --no-cache add g++ make autoconf \
  && pecl install redis \
  && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini \
  && apk del g++ make autoconf \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q \
    | php -- --quiet \
    && mv composer.phar /usr/local/bin/composer

COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
