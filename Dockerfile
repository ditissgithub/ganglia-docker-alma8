FROM centos:7
LABEL maintainer="ditissgithub"

RUN echo "root:admin@@321" | chpasswd
RUN yum install sudo -y
RUN sed -i '34i Cmnd_Alias GANG_SERVICES = /usr/sbin/httpd, /usr/sbin/gmetad, /usr/sbin/gmond, /entrypoint.sh' /etc/sudoers
RUN sed -i '101i ganglia_user ALL=(ALL) NOPASSWD: GANG_SERVICES' /etc/sudoers

ENV HOME /ganglia_seva
ENV DEBIAN_FRONTEND=noninteractive

RUN yum install -y epel-release
RUN yum install -y httpd ganglia rrdtool ganglia-gmetad ganglia-gmond ganglia-web
RUN sed -i '/ServerName www.example.com:80/a ServerName localhost' /etc/httpd/conf/httpd.conf

COPY gmetad.conf /etc/ganglia/gmetad.conf
COPY gmond.conf /etc/ganglia/gmond.conf
COPY ganglia.conf /etc/httpd/conf.d/ganglia.conf

RUN htpasswd -c -b /etc/httpd/auth.basic adminganglia admin
RUN echo -e "Alias /ganglia /usr/share/ganglia \n\
<Location /ganglia>\n\
AuthType basic\n\
AuthName \"Ganglia web UI\"\n\
AuthBasicProvider file\n\
AuthUserFile \"/etc/httpd/auth.basic\"\n\
Require user adminganglia\n\
</Location>" > /etc/httpd/conf.d/ganglia.conf

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN groupadd -r ganglia_user && useradd -r -g ganglia_user ganglia_user
RUN echo "ganglia_user:guser@@123" | chpasswd
USER ganglia_user
