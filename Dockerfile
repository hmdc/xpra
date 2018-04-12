FROM fedora:latest
RUN mkdir /var/run/dbus
RUN mkdir -p /run/user/0/xpra/
RUN mkdir -p /var/lib/dbus
RUN yum -y update && \
    rpm --import https://winswitch.org/gpg.asc && \
    cd /etc/yum.repos.d/ && \
    yum install -y curl && \
    curl -O https://winswitch.org/downloads/Fedora/winswitch.repo && \
    yum -y update && \
    yum -y install xpra
