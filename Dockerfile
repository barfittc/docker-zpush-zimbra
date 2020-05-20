FROM php:7.4-apache

RUN rm /etc/apt/preferences.d/no-debian-php

RUN apt update && \
	apt install -y dnsutils libxml2-dev && \
	apt-get clean

RUN docker-php-ext-install sysvmsg && \
	docker-php-ext-install sysvsem && \
	docker-php-ext-install sysvshm && \
	docker-php-ext-install xml && \
	docker-php-ext-install soap


ENV VERSION 2.3
ENV VERSIONFULL 2.3.9
ENV BACKENDVERSION 69
ENV TERM xterm

#ip=$(dig +short zimbra)
#sed 's/.*zimbra.*/$ip        zimbra.flmaine.com/'  file
# Create directory for zpush

# Install zpush
RUN cd /var/www/html && \
	curl -L "http://download.z-push.org/final/${VERSION}/z-push-${VERSIONFULL}.tar.gz" | tar --strip-components=1 -x -z 

# Add zimbra backend
RUN cd /var/www/html/backend  && \
	curl -o zpzb-install.sh -L "https://sourceforge.net/projects/zimbrabackend/files/Release${BACKENDVERSION}/zpzb-install.sh/download"  && \
	curl -o zimbra${BACKENDVERSION}.tgz  -L "http://downloads.sourceforge.net/project/zimbrabackend/Release${BACKENDVERSION}/zimbra${BACKENDVERSION}.tgz" 
	
RUN cd /var/www/html/backend &&\
	chmod +x zpzb-install.sh &&\
	sed -i "/chcon[^']*$/d" zpzb-install.sh &&\
	/bin/bash ./zpzb-install.sh $BACKENDVERSION ; exit 0

# Create directory for zpush
RUN mkdir -p /var/log/z-push && mkdir /var/lib/z-push
RUN chown www-data:www-data -R /var/lib/z-push /var/log/z-push /var/www/html

# Add vhost for zpush
COPY default-vhost.conf /etc/apache2/sites-enabled/000-default.conf

# Expose Apache
EXPOSE 80

COPY ./entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

RUN rm /var/www/html/backend/zimbra/config.php
COPY ./zimbra.config.php /var/www/html/backend/zimbra/config.php
RUN rm /var/www/html/backend/zimbra/zimbra.php
COPY ./zimbra.backend.php /var/www/html/backend/zimbra/zimbra.php

RUN rm /var/www/html/index.php
COPY ./zpush.index.php /var/www/html/index.php
RUN rm /var/www/html/config.php
COPY ./zpush.config.php /var/www/html/config.php

ENTRYPOINT ["/bin/bash", "/opt/entrypoint.sh"]
