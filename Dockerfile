FROM rhel7

MAINTAINER docker@softwarecollections.org

RUN yum update -y && yum install -y yum-utils && \
    yum-config-manager --enable rhel-server-rhscl-7-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum install -y --setopt=tsflags=nodocs mariadb55 && yum clean all


EXPOSE 3306

ADD ./enablemariadb55.sh /etc/profile.d/
ADD ./cont-entry /usr/local/bin/
ADD ./mysqld.sh /usr/local/libexec/cont-entry.d/mysqld.sh
ADD ./mysqld-cont.cnf /opt/rh/mariadb55/root/etc/my.cnf.d/mysqld-cont.cnf
ADD ./init-base.sh /usr/local/libexec/cont-mysqld-init.d/init-base.sh
ADD ./cont-setup.sh /usr/local/libexec/cont-setup.sh

RUN	/usr/local/libexec/cont-setup.sh && \
	:

USER mysql

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["cont-entry"]

CMD ["mysqld"]
