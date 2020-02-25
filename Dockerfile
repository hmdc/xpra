ARG FEDORA_VERSION=30
FROM fedora:${FEDORA_VERSION}
ARG XPRA_VERSION=3.0
ARG GIT_SHA
ARG GIT_DATE
ARG BUILD_DATE
ARG MAINTAINER
ARG MAINTAINER_URL

LABEL "xpra.version"="$XPRA_VERSION" \
      "git.sha"="$GIT_SHA" \
      "git.date"="$GIT_DATE" \
      "build.date"="$BUILD_DATE" \
      "maintainer"="$MAINTAINER" \
      "maintainer.url"="$MAINTAINER_URL"

EXPOSE 8080
RUN mkdir /var/run/dbus && \
    mkdir -p /run/user/0/xpra/ && \
    mkdir -p /var/lib/dbus && \
    yum -y update && \
    rpm --import https://winswitch.org/gpg.asc && \
    cd /etc/yum.repos.d/ && \
    yum install -y curl && \
    curl -O https://winswitch.org/downloads/Fedora/winswitch.repo && \
    yum -y update && \
    yum -y install rxvt xpra-${XPRA_VERSION} dnf-plugins-core x264-xpra ffmpeg-xpra && \
    yum -y clean all
ENTRYPOINT ["/usr/bin/xpra", "start-desktop", "--swap-keys=no", "--start-child=/usr/bin/rxvt", "--daemon=off", "--bind-tcp=0.0.0.0:8080", "--no-mdns", "--html=on", "--no-notifications", "--no-pulseaudio", "--desktop-fullscreen=True", "--exit-with-children"]
