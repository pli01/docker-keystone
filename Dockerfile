FROM debian:jessie-backports

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy sqlite curl && \
    apt-get install -t jessie-backports -qy keystone python-keystone
ADD ./keystone.conf /etc/keystone/keystone.conf
ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN cd /var/lib/keystone && keystone-manage db_sync
EXPOSE 5000 35357
CMD ["/usr/bin/entrypoint.sh"]
