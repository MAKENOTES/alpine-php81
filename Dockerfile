FROM php:8.1.2-fpm-alpine

ARG TZ=Asia/Shanghai
ARG PHP_EXTENSIONS=pdo_mysql,mysqli,mbstring,gd,curl,opcache,redis,memcached,mongodb,bcmath,exif,imagick,pcntl,protobuf,soap,sockets,swoole,yaf,zip
ARG CONTAINER_PACKAGE_URL=mirrors.aliyun.com


RUN if [ $CONTAINER_PACKAGE_URL ] ; then sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories ; fi


COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh | tee /tmp/install_php.log \
    && rm -rf /tmp/extensions

ADD ./extensions/install-php-extensions  /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone


# Fix: https://github.com/docker-library/php/issues/240
RUN apk add gnu-libiconv=1.16-r0 libstdc++ --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


RUN apk add libgcc libx11 glib libxrender libxext libintl ttf-freefont fontconfig \
    && apk add libssl1.0 --update-cache --repository http://mirrors.ustc.edu.cn/alpine/v3.8/main/ --allow-untrusted