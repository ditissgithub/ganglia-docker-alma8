FROM almalinux/8-base:latest
LABEL maintainer="ditissgithub"

RUN echo "root:admin@@321" | chpasswd
RUN yum install sudo -y
RUN sed -i '34i Cmnd_Alias GANG_SERVICES = /usr/sbin/httpd, /usr/sbin/gmetad, /usr/sbin/gmond, /entrypoint.sh' /etc/sudoers
RUN sed -i '101i ganglia_user ALL=(ALL) NOPASSWD: GANG_SERVICES' /etc/sudoers

ENV HOME /ganglia_seva
ENV DEBIAN_FRONTEND=noninteractive

RUN yum install -y epel-release
RUN yum install -y httpd ganglia rrdtool ganglia-gmetad ganglia-gmond ganglia-web

COPY httpd_initscripts /etc/init.d/httpd
COPY ./etc_ganglia /ganglia_conf
COPY supervisord.conf /etc/supervisord.conf


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chmod +x /etc/init.d/httpd && \
RUN groupadd -r ganglia_user && useradd -r -g ganglia_user ganglia_user
RUN echo "ganglia_user:guser@@123" | chpasswd
USER ganglia_user

EXPOSE 80 81 8649
CMD ["/entrypoint.sh"]
