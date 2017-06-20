FROM php:5.6-apache
MAINTAINER Ridwan Shariffdeen <ridwan@orangehrmlive.com>

WORKDIR /var/www/html


#Install dependent software
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
    cron \
    libreoffice-common \
    libreoffice-draw \
    libreoffice-writer \
    libpng12-dev \
    libjpeg-dev \
    libxml2-dev \
    mysql-client \
    poppler-utils \
    ttf-unifont \
    unzip \
    zip

#Install libraries required to compile PHP modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libgd-tools \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libmcrypt-dev \
    libssh2-1-dev \
    memcached \
    zlib1g-dev

# Configure PHP modules
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu  \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu

# Install PHP modules
RUN  docker-php-ext-install \
     bcmath \
     calendar \
     exif \
     gd \
     gettext \
     ldap \
     mysql \
     mysqli \
     pdo \
     pdo_mysql \
     opcache \
     soap \
     zip

# Install PHP extended community libraries
RUN yes "" | pecl install channel://pecl.php.net/APCu-4.0.11 \
    && pecl install \
         ssh2 \
         stats \
    && docker-php-ext-enable \
         apcu \
         ssh2 \
         stats

# Remove apps not needed and clean apt cache
RUN apt-get purge -y --auto-remove \
        libfreetype6-dev \
        libgd-tools \
        libjpeg62-turbo-dev \
        libjpeg-dev \
        libldap2-dev \
        libmcrypt-dev \
        libpng12-dev \
        libssh2-1-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Enable apache mods.
RUN a2enmod php5 rewrite expires headers ssl

# Update the default apache site with the config we created.
COPY apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# Export port 443
EXPOSE 443

# Copy files
COPY ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20121212/ioncube_loader_lin_5.6.so
COPY php.ini /usr/local/etc/php/php.ini


CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
