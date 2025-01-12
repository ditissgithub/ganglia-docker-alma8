FROM almalinux/8-base:latest
LABEL maintainer="ditissgithub"

RUN yum install sudo -y

RUN yum install -y epel-release
RUN yum install -y httpd ganglia rrdtool ganglia-gmetad ganglia-gmond ganglia-web

COPY ./httpd_initscripts /etc/init.d/httpd
COPY ./etc_ganglia /ganglia_conf
COPY ./supervisord.conf /etc/supervisord.conf


ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chmod +x /etc/init.d/httpd 

EXPOSE 9002 81 8649
CMD ["/entrypoint.sh"]
