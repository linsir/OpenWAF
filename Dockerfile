####################################################
# Dockerfile to build OpenWAF container images
# Based on jessie
####################################################

# Set the base image to jessie
FROM debian:jessie

# File Author
MAINTAINER Linsir

# Docker Build Arguments
ARG OPENWAF_PREFIX="/opt"
ARG OPENRESTY_PREFIX="/usr/local/openresty"
ARG OPENRESTY_VERSION="1.13.6.1"
ARG PCRE_VERSION="8.40"
ARG OPENSSL_VERSION="1.0.2k"
ARG CONFIG_OPTIONS=" \ 
    --with-pcre-jit \ 
    --with-http_stub_status_module \ 
    --with-http_ssl_module \ 
    --with-http_realip_module \ 
    --with-http_sub_module \ 
    --with-http_geoip_module \ 
    --with-openssl=${OPENWAF_PREFIX}/openssl-${OPENSSL_VERSION} \ 
    --with-pcre=${OPENWAF_PREFIX}/pcre-${PCRE_VERSION} \ 
    "
# ./configure --with-pcre-jit --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-http_sub_module --with-http_geoip_module --with-openssl=/opt/openssl-1.0.2k --with-pcre=/opt/pcre-8.40

#  change soureslist
RUN echo "deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib" > /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install wget curl -y

# 1.install openrestry related
RUN apt-get install make perl build-essential zlib1g-dev libgeoip-dev libncurses5-dev libreadline-dev -y \
    && cd ${OPENWAF_PREFIX} \
    && wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz \
    && wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
    && tar -zxvf pcre-${PCRE_VERSION}.tar.gz \
    && tar -zxvf openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -zxvf openresty-${OPENRESTY_VERSION}.tar.gz 

# 2. install OpenWAF
RUN cd ${OPENWAF_PREFIX} \ 
    && apt-get install git swig -y \ 
    && git clone https://github.com/linsir/OpenWAF.git \ 
    && mv ${OPENWAF_PREFIX}/OpenWAF/lib/openresty/ngx_openwaf.conf /etc \ 
    && mv ${OPENWAF_PREFIX}/OpenWAF/lib/openresty/configure ${OPENWAF_PREFIX}/openresty-${OPENRESTY_VERSION} \ 
    && cp -RP ${OPENWAF_PREFIX}/OpenWAF/lib/openresty/* ${OPENWAF_PREFIX}/openresty-${OPENRESTY_VERSION}/bundle/ \ 
    && cd ${OPENWAF_PREFIX}/OpenWAF \ 
    && make install 

# 3. install openresty
RUN cd ${OPENWAF_PREFIX}/openresty-${OPENRESTY_VERSION}/ \  
    && ./configure ${CONFIG_OPTIONS} \
    && make \
    && make install 

RUN cd ${OPENWAF_PREFIX} \ 
    && rm -rf \ 
    pcre-${PCRE_VERSION} \ 
    openssl-${OPENSSL_VERSION} \ 
    pcre-${PCRE_VERSION}.tar.gz \ 
    openresty-${OPENRESTY_VERSION} \ 
    openssl-${OPENSSL_VERSION}.tar.gz \ 
    openresty-${OPENRESTY_VERSION}.tar.gz
# set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV PATH=${OPENRESTY_PREFIX}/nginx/sbin/:${OPENRESTY_PREFIX}/bin/:$PATH

ENTRYPOINT ["openresty", "-c", "/etc/ngx_openwaf.conf", "-g", "daemon off;"]

