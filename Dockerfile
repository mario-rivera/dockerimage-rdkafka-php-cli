FROM php:7.3-cli

ENV WORKDIR /app

ENV LIBRDKAFKA_VERSION v0.9.5

ENV BUILD_DEPS \
    build-essential \
    libzip-dev \
    libsasl2-dev \
    libssl-dev \
    python-minimal \
    zlib1g-dev \
    git \
    zip

    # install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends ${BUILD_DEPS} \
    # install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    # build lib rdkafka
    && cd /tmp \
    && git clone \
        --branch ${LIBRDKAFKA_VERSION} \
        --depth 1 \
        https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install \
    # install php extensions
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install \
        zip \
    && pecl install \
        xdebug-2.7.1 rdkafka-3.1.0 \
    && docker-php-ext-enable \
        xdebug rdkafka \
    # remove
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/librdkafka

# PHP ini file
COPY php/conf/php.ini-production /usr/local/etc/php/php.ini
# Xdebug config
COPY php/xdebug/xdebug.config.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.config.ini

WORKDIR ${WORKDIR}