FROM debian:bullseye

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget
RUN apt-get install -y php7.4\
  php-fpm\
  php-mysql\
  mariadb-client

RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www \
&& cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz

RUN chown -R root:root /var/www/wordpress

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh

RUN mkdir -p /run/php 

ENTRYPOINT ["/usr/local/bin/config.sh"]