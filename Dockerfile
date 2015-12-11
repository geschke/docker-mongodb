FROM debian:jessie

MAINTAINER Ralf Geschke <ralf@kuerbis.org>

# mostly taken from https://github.com/sameersbn/docker-mongodb

ENV MONGO_USER=mongodb \
    MONGO_DATA_DIR=/var/lib/mongodb \
    MONGO_LOG_DIR=/var/log/mongodb

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates curl \
		numactl \
	&& rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
		&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
		&& gpg --verify /usr/local/bin/gosu.asc \
		&& rm /usr/local/bin/gosu.asc \
		&& chmod +x /usr/local/bin/gosu

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
	 && echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
	 && apt-get update \
	 && apt-get install -y mongodb-org \
   && sed 's/bindIp: 127.0.0.1/#bindIp: 127.0.0.1/' -i /etc/mongod.conf \
	 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "${MONGO_DATA_DIR}" \
  && chmod -R 0755 "${MONGO_DATA_DIR}" \
  && chown -R "${MONGO_USER}":"${MONGO_USER}" "${MONGO_DATA_DIR}" \
  && mkdir -p "${MONGO_LOG_DIR}" \
  && chmod -R 0755 "${MONGO_LOG_DIR}" \
  && chown -R "${MONGO_USER}":"${MONGO_USER}" "${MONGO_LOG_DIR}"

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

WORKDIR "${MONGO_DATA_DIR}"

EXPOSE 27017/tcp
VOLUME ["${MONGO_DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["mongod"]

