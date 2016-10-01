FROM openjdk:8-jre
RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
&& rm -rf /var/lib/apt/lists/*

# Inspired by h3nrik/apacheds

# ApacheDS installation

ENV APACHEDS_VERSION 2.0.0-M20
ENV APACHEDS_ARCH amd64

ENV APACHEDS_ARCHIVE apacheds-${APACHEDS_VERSION}-${APACHEDS_ARCH}.deb
ENV APACHEDS_DATA /var/lib/apacheds
ENV APACHEDS_USER apacheds
ENV APACHEDS_GROUP apacheds

VOLUME ${APACHEDS_DATA}

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y ldap-utils procps curl \
    && curl http://www.eu.apache.org/dist//directory/apacheds/dist/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE} > ${APACHEDS_ARCHIVE} \
    && dpkg -i ${APACHEDS_ARCHIVE} \
	&& rm ${APACHEDS_ARCHIVE}

# ApacheDS bootstrap configuration

ENV APACHEDS_INSTANCE default
ENV APACHEDS_BOOTSTRAP /bootstrap
ENV APACHEDS_SCRIPT docker-entrypoint.sh

COPY ${APACHEDS_SCRIPT} /${APACHEDS_SCRIPT}
RUN chown ${APACHEDS_USER}:${APACHEDS_GROUP} /${APACHEDS_SCRIPT} \
    && chmod u+rx /${APACHEDS_SCRIPT}

COPY config/* ${APACHEDS_BOOTSTRAP}/conf/
RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions \
    && chown -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_BOOTSTRAP}

# ApacheDS wrapper command

EXPOSE 10389 10636 60088 60464 8080 8443
CMD ["/docker-entrypoint.sh"]
