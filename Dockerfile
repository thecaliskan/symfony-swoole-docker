FROM php:8.1-alpine

# Install dev dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev

# Install production dependencies
RUN apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    icu-libs \
    imagemagick \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    make \
    mysql-client \
    oniguruma-dev \
    postgresql-libs \
    supervisor \
    zlib-dev

# Install PECL and PEAR extensions
RUN pecl install \
    redis \
    imagick \
    openswoole

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
    redis \
    imagick \
    openswoole

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    calendar \
    curl \
    exif \
    gd \
    intl \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    soap \
    xml \
    zip

# Install Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash
RUN apk add --no-cache  \
    symfony-cli

# Cleanup dev dependencies
RUN apk del -f .build-deps

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH $PATH:/root/.composer/vendor/bin
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Supervisor
RUN printf "\n[supervisord]\npidfile=/run/supervisord.pid\nuser=root\n" >>  /etc/supervisord.conf
COPY supervisor.d /etc/supervisor.d

# Setup working directory
WORKDIR /var/www

# Port Expose
EXPOSE 80

# Entrypoint
COPY start-container /usr/local/bin/start-container

ENV APP_ENV=prod
ENV SWOOLE_RUNTIME=1

ENTRYPOINT ["start-container"]
