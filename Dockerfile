FROM fedora:30
ENV XPRA_VERSION "2.5.1"
RUN mkdir /var/run/dbus
RUN mkdir -p /run/user/0/xpra/
RUN mkdir -p /var/lib/dbus
RUN yum -y update && \
    rpm --import https://winswitch.org/gpg.asc && \
    cd /etc/yum.repos.d/ && \
    yum install -y curl && \
    curl -O https://winswitch.org/downloads/Fedora/winswitch.repo && \
    yum -y update && \
    yum -y install rxvt xpra-${XPRA_VERSION}
ENTRYPOINT ["/usr/bin/xpra"]
