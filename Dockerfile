FROM ubuntu:14.04.5
MAINTAINER Doro Wu <fcwu.tw@gmail.com>

ENV HOME=/home/ubuntu \
    TINI_VERSION=v0.9.0

# cache
RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends software-properties-common curl \
    && sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | sudo apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
    # tini for subreap                                   
    && curl -sSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini > /bin/tini \
    && chmod +x /bin/tini \
    # cleanup
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# build nginx with rtmp
RUN apt-get update \
    && apt-get source nginx \
    && apt-get build-dep -y nginx \
    && curl -sSL https://github.com/arut/nginx-rtmp-module/archive/v1.1.10.tar.gz | tar xzvf - \
    && cd nginx-1.4.6 \
    && ./configure --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_spdy_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --add-module=../nginx-rtmp-module-1.1.10 \
    && mv ../nginx-rtmp-module-1.1.10/stat.xsl /usr/share/nginx/html/ \
    && make \
    && make install \
    && cd ../ \
    && rm -rf nginx-* \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# ffmpeg
RUN curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz | tar xJvf - \
    && mv ffmpeg-*/ffmpeg /usr/local/bin/ffmpeg \
    && rm -rf ffmpeg-*

COPY root /

# web
RUN pip install setuptools wheel && pip install -r /web/requirements.txt

EXPOSE 80
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
