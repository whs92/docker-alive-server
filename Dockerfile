FROM ubuntu:20.04

ENV http_proxy http://www.bessy.de:3128
ENV https_proxy http://www.bessy.de:3128
ENV LD_LIBRARY_PATH=/usr/local/lib
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update \
&& apt-get -y install sudo \
&& apt-get -y install apt-utils  \
&& apt-get -y install build-essential \
&& apt-get -y install dialog \
&& apt-get -y install apache2

EXPOSE 80
EXPOSE 5678
EXPOSE 5679
EXPOSE 5680

WORKDIR /alive
COPY /alived /alive/alived
COPY /client-tools /alive/client-tools
COPY /dcgi /alive/dcgi
COPY /web-client /alive/web-client
COPY /alived/init/alived_config.txt /alive/alived_config.txt
COPY start.sh start.sh
RUN ls *

# Make and install the alive Daemon
RUN cd /alive/alived \
&& make \
&& make install
RUN mkdir -p /local/alived

# Make and install dcgi
RUN cd /alive/dcgi \
&& make \
&& make install

# Make and install the client tools
RUN  cd /alive/client-tools \
&& make \
&& make install 

# Enable cgi in apache
RUN cd /etc/apache2/mods-enabled/ \
&& a2enmod cgi

# Make and install the web client
RUN cd /alive/web-client \
&& make \
&& make install

# Make sure the server can run the cgi file
RUN cd /usr/lib/cgi-bin \
&& chown www-data:www-data ioc_alive.cgi
RUN chmod a+x start.sh

# Start the alive daemon and the apache2 webserver
CMD ["/alive/start.sh"]
