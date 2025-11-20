FROM ubuntu:22.04

LABEL maintainer="hello@kesaralive.com"
LABEL description="Apache / PHP development environment"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# Add PHP PPA
RUN add-apt-repository ppa:ondrej/php -y

RUN apt-get update && apt-get install -y \
    apache2 \
    php8.0 \
    libapache2-mod-php8.0 \
    php8.0-bcmath \
    php8.0-gd \
    php8.0-sqlite3 \
    php8.0-mysql \
    php8.0-curl \
    php8.0-xml \
    php8.0-mbstring \
    php8.0-zip \
    nano

# Locales
RUN apt-get install -y locales && \
    locale-gen fr_FR.UTF-8 && \
    locale-gen en_US.UTF-8 && \
    locale-gen de_DE.UTF-8

# PHP dev config (show errors)
RUN sed -i 's/^error_reporting = .*/error_reporting = E_ALL/' /etc/php/8.0/apache2/php.ini && \
    sed -i 's/^display_errors = .*/display_errors = On/' /etc/php/8.0/apache2/php.ini && \
    sed -i 's/^zlib.output_compression = .*/zlib.output_compression = Off/' /etc/php/8.0/apache2/php.ini

ENV TERM xterm

# Apache config
RUN a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN chgrp -R www-data /var/www && \
    find /var/www -type d -exec chmod 775 {} + && \
    find /var/www -type f -exec chmod 664 {} +

EXPOSE 80

CMD ["/usr/sbin/apache2ctl","-DFOREGROUND"]
