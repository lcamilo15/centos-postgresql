FROM        centos:7

# explicitly set user/group IDs
RUN groupadd -r -f postgres --gid=990 && useradd -o -r -g postgres --uid=990 postgres

# # grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
    && yum update -y && yum install -y ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -fr "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN yum update -y && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

RUN mkdir /docker-entrypoint-initdb.d

ENV PG_MAJOR 9.5
ENV PG_VERSION 9.5-2.noarch

RUN echo "exclude=postgresql*" >> /etc/yum.repos.d/CentOS-Base.repo \
    && yum install -y https://download.postgresql.org/pub/repos/yum/$PG_MAJOR/redhat/rhel-7-x86_64/pgdg-centos95-$PG_VERSION.rpm \
    && yum update -y \
    && yum install -y postgresql95-server postgresql95-contrib

# make the sample config easier to munge (and "correct by default")
RUN mkdir -p /usr/share/postgresql/ && mv -v /usr/pgsql-$PG_MAJOR/share/postgresql.conf.sample /usr/share/postgresql/ \
    && ln -sv /usr/share/postgresql/postgresql.conf.sample /usr/pgsql-$PG_MAJOR/share/ \
    && sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*(\s+#)/\1 = '*'\2/" /usr/share/postgresql/postgresql.conf.sample \
    && sed -ri "s/^#?(logging_collector\s*=\s*\S+.*)/#\1/" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql /var/lib/postgresql/data && chown -R postgres:postgres /var/run/postgresql /var/lib/postgresql

ENV PATH /usr/pgsql-9.5/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

ENV CONFIG_FILE /var/lib/postgresql/conf/postgresql.conf
ENV HBA_FILE /var/lib/postgresql/conf/pg_hba.conf
ENV IDENT_FILE /var/lib/postgresql/conf/pg_ident.conf

VOLUME /var/lib/postgresql/data
VOLUME /var/lib/postgresql/conf

COPY docker-entrypoint.sh /

COPY run.sh /run.sh
COPY run_old.sh /run_old.sh
COPY conf/ /var/lib/postgresql/conf/


ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["/run.sh"]