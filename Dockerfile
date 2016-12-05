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

COPY root /

# web
RUN pip install setuptools wheel && pip install -r /web/requirements.txt

EXPOSE 80
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
