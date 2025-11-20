# Use Ubuntu 20.04 as base image
FROM ubuntu:20.04

LABEL maintainer="hello@kesaralive.com"
LABEL description="Apache / PHP development environment"

# Set non-interactive frontend for apt
ARG DEBIAN_FRONTEND=noninteractive

# Update base packages and install dependencies
RUN apt-get update && apt-get install -y \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    curl \
    gnupg2 \
    locales \
    nano \
    unzip \
    wget \
    && apt-get clean

# Add PHP PPA repository
RUN add-apt-repository ppa:ondrej/php -y
RUN apt-get update

# Install Apache + PHP 8.1 (PHP 8.0 is end-of-life, PHP 8.1 is recommended)
RUN apt-get install -y \
    apache2 \
    php8.1 \
    libapache2-mod-php8.1 \
    php8.1-bcmath \
    php8.1-gd \
    php8.1-sqlite3 \
    php8.1-mysql \
    php8.1-curl \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-zip \
    mcrypt \
    && apt-get clean

# Set locales
RUN locale-gen en_US.UTF-8 fr_FR.UTF-8 de_DE.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Configure PHP for development
RUN sed -i 's/^error_reporting\s*=.*/error_reporting = E_ALL/' /etc/php/8.1/apache2/php.ini \
    && sed -i 's/^display_errors\s*=.*/display_errors = On/' /etc/php/8.1/apache2/php.ini \
    && sed -i 's/^zlib.output_compression\s*=.*/zlib.output_compression = Off/' /etc/php/8.1/apache2/php.ini

# Configure Apache
RUN a2enmod rewrite \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Fix permissions
RUN chgrp -R www-data /var/www \
    && find /var/www -type d -exec chmod 775 {} + \
    && find /var/www -type f -exec chmod 664 {} +

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["/usr/sbin/apache2ctl","-DFOREGROUND"]
