FROM fedora:30
ENV XPRA_VERSION "3.0"
EXPOSE 8080
RUN mkdir /var/run/dbus
RUN mkdir -p /run/user/0/xpra/
RUN mkdir -p /var/lib/dbus
RUN yum -y update && \
    rpm --import https://winswitch.org/gpg.asc && \
    cd /etc/yum.repos.d/ && \
    yum install -y curl && \
    curl -O https://winswitch.org/downloads/Fedora/winswitch.repo && \
    yum -y update && \
    yum -y install rxvt xpra-${XPRA_VERSION} dnf-plugins-core x264-xpra ffmpeg-xpra
ENTRYPOINT ["/usr/bin/xpra", "start-desktop", "--swap-keys=no", "--start-child=/usr/bin/rxvt", "--daemon=off", "--bind-tcp=0.0.0.0:8080", "--no-mdns", "--html=on", "--no-notifications", "--no-pulseaudio", "--desktop-fullscreen=True", "--exit-with-children"]
