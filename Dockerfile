FROM fedora:30
ENV XPRA_VERSION "2.5.0"
RUN mkdir /var/run/dbus
RUN mkdir -p /run/user/0/xpra/
RUN mkdir -p /var/lib/dbus
RUN yum -y update && \
    rpm --import https://winswitch.org/gpg.asc && \
    cd /etc/yum.repos.d/ && \
    yum install -y curl && \
    curl -O https://winswitch.org/downloads/Fedora/winswitch.repo && \
    yum -y update && \
    yum -y install rxvt xpra-${XPRA_VERSION} dnf-plugins-core && \
    dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    yum -y install xpra-codecs-freeworld
ENTRYPOINT ["/usr/bin/xpra"]
