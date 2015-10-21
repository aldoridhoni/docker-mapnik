docker-mapnik
===================

The purpose of this project is to provide a tile server using mapnik and tilestache.

## Mapnik

Mapnik is a Free Toolkit for developing mapping applications. It's written in C++ and there are Python bindings to facilitate fast-paced agile development. It can comfortably be used for both desktop and web development

## TileStache

TileStache is a Python-based server application that can serve up map tiles based on rendered geographic data.

## Building docker-mapnik

Running this will build a docker image with mapnik 3.0.7 and TileStache.

    git clone https://github.com/aldoridhoni/docker-mapnik
    cd docker-mapnik
    docker build -t mapnik-tilestache .


## Running docker-mapnik

This image expose two ports 80 for Nginx/TileStache and 9001 for supervisord

    sudo docker run -d -p 9001:9001 -p 8000:80 -v (readlink --canonicalize .):/etc/tilestache/resources --name mapnik-ts mapnik-tilestache


## Supervisord remote access

Default user and password are: ma/ma1337

### Side note on tilestache

Use ressources folder to synchronize your mapnik styles.
Modify tilestache.cfg according to your needs, it should be synchronized with your Docker.
Don't forget to restart tilestache from uwsgi / supervisord.

### Issue
There is currently no newer `HarfBuzz >= 0.9.34` for ubuntu:14.04
