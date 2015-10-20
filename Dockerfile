# Mapnik for Docker

FROM ubuntu:wily
MAINTAINER Fabien Reboia<srounet@gmail.com>

ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Essential stuffs
RUN apt-get update && apt-get -qq install -y --no-install-recommends \
	build-essential \
	sudo \
	software-properties-common \
	curl

# Boost
RUN apt-get -qq install -y --no-install-recommends \
	libboost-dev \
	libboost-filesystem-dev \
	libboost-program-options-dev \
	libboost-python-dev \
	libboost-regex-dev \
	libboost-system-dev \
	libboost-thread-dev

# Mapnik dependencies
RUN apt-get -qq install -y --no-install-recommends \
	libicu-dev \
	libtiff4-dev \
	libfreetype6-dev \
	libpng12-dev \
	libxml2-dev \
	libproj-dev \
	libsqlite3-dev \
	libgdal-dev \
	libcairo-dev \
	python-cairo-dev \
	postgresql-contrib \
	libharfbuzz-dev

# Mapnik 3.0.7
RUN curl -s https://mapnik.s3.amazonaws.com/dist/v3.0.7/mapnik-v3.0.7.tar.bz2 | tar -xj -C /tmp/ && cd /tmp/mapnik-v3.0.7 && python scons/scons.py configure JOBS=4 && make && make install JOBS=4 && cd / && rm -rf /tmp/mapnik-v3.0.7

# TileStache and dependencies
RUN ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
RUN cd /tmp/ && curl --insecure -Os https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py && python get-pip.py
RUN apt-get install python-pil
RUN pip install -U modestmaps simplejson werkzeug tilestache --allow-external PIL --allow-unverified PIL
RUN mkdir -p /etc/tilestache
COPY etc/run_tilestache.py /etc/tilestache/

# Uwsgi
RUN pip install uwsgi && mkdir -p /etc/uwsgi/apps-enabled && mkdir -p /etc/uwsgi/apps-available
COPY etc/uwsgi_tilestache.ini /etc/uwsgi/apps-available/tilestache.ini
RUN ln -s /etc/uwsgi/apps-available/tilestache.ini /etc/uwsgi/apps-enabled/tilestache.ini

# Supervisor
RUN pip install supervisor
RUN echo_supervisord_conf > /etc/supervisord.conf && printf "[include]\\nfiles = /etc/supervisord/*" >> /etc/supervisord.conf
RUN mkdir -p /etc/supervisord
COPY etc/supervisor_uwsgi.ini /etc/supervisord/uwsgi.ini
COPY etc/supervisor_inet.conf /etc/supervisord/inet.conf
COPY etc/init_supervisord /etc/init.d/supervisord
RUN chmod +x /etc/init.d/supervisord

# Nginx
RUN add-apt-repository -y ppa:nginx/stable \
	&& apt-get -qq update \
	&& apt-get -qq install -y nginx \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y
COPY etc/nginx_site.conf /etc/nginx/sites-available/site.conf
RUN ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Start services
RUN /etc/init.d/supervisord start
RUN service nginx start

EXPOSE 80 9001

ENV HOST_IP `ifconfig | grep inet | grep Mask:255.255.255.0 | cut -d ' ' -f 12 | cut -d ':' -f 2`

ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]
