FROM ubuntu as ubuntu-base

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        xfce4 xfce4-goodies gnome-icon-theme tightvncserver \
        bzip2 \
        python \
        python2 \
        sudo \
        gdebi \
        supervisor \
        xvfb x11vnc novnc websockify \
        zip \
        unzip \
        ssh \
        npm \
        wget \
        software-properties-common \
    && npm install -g wstunnel \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*   


RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html
RUN adduser yanz

RUN gpasswd -a yanz sudo
RUN echo yanz:123456|chpasswd
RUN su - yanz


COPY scripts/* /opt/bin/

# Add Supervisor configuration file
COPY supervisord.conf /etc/supervisor/

# Relaxing permissions for other non-sudo environments
RUN  mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 777 /opt/bin/ /var/run/supervisor /var/log/supervisor /etc/passwd \
    && chgrp -R 0 /opt/bin/ /var/run/supervisor /var/log/supervisor \
    && chmod -R g=u /opt/bin/ /var/run/supervisor /var/log/supervisor

# Creating base directory for Xvfb
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

CMD ["/opt/bin/entry_point.sh"]

#============================
# Utilities
#============================
FROM ubuntu-base as ubuntu-utilities

RUN apt-get -qqy update \
    && apt install unzip \
    && dpkg --configure -a \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -qqy --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
    
RUN wget -c http://archive.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-5.1ubuntu2_amd64.deb \
    && apt-get install -y -qqy --no-install-recommends ./python-gtk2_2.24.0-5.1ubuntu2_amd64.deb
    
RUN wget -c https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.6/fahclient_7.6.21_amd64.deb \
    && wget -c https://download.foldingathome.org/releases/public/release/fahcontrol/debian-stable-64bit/v7.6/fahcontrol_7.6.21-1_all.deb \
    && wget -c https://download.foldingathome.org/releases/public/release/fahviewer/debian-stable-64bit/v7.6/fahviewer_7.6.21_amd64.deb
    
RUN apt-get install -y -qqy --no-install-recommends ./fahclient_7.6.21_amd64.deb
RUN apt-get install -y -qqy --no-install-recommends ./fahcontrol_7.6.21-1_all.deb
RUN apt-get install -y -qqy --no-install-recommends ./fahviewer_7.6.21_amd64.deb

# COPY conf.d/* /etc/supervisor/conf.d/


#============================
# GUI
#============================
FROM ubuntu-utilities as ubuntu-ui

ENV SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    SCREEN_DPI=96 \
    DISPLAY=:99 \
    DISPLAY_NUM=99 \
    UI_COMMAND=/usr/bin/startxfce4

# RUN apt-get update -qqy \
#     && apt-get -qqy install \
#         xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable kde-plasma-desktop

RUN apt-get update -qqy \
    && apt-get -qqy install --no-install-recommends \
        dbus-x11 xfce4 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
