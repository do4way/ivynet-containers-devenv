###############################################
#  Ivynet development environment docker
###############################################

FROM ubuntu:16.04

ENV NGINX_VERSION 1.10.3-0ubuntu0.16.04.2

#  update repositories
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y software-properties-common  \
  && apt-get install -y byobu curl git htop man unzip vim wget dnsutils net-tools iputils-ping  \
  && apt-get install -y make build-essential zlib1g-dev libbz2-dev libreadline-dev \
  && apt-get install -y sqlite3 libsqlite3-dev \
  && apt-get install -y libssl-dev \
  && apt-get install --no-install-recommends --no-install-suggests -y \
                      nginx=${NGINX_VERSION} \
  && apt-get install -y postgresql \
  && apt-get -y --purge autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN \
  add-apt-repository -y ppa:gophers/archive \
  && apt-get update \
  && apt-get install -y golang-1.9-go python2.7 redis-tools \
  && apt-get -y --purge autoremove \
  && rm -rf /var/lib/apt/lists/*

# Install java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# install hadoop client
ENV HADOOP_VERSION 2.8.1
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_KEY_URL https://dist.apache.org/repos/dist/release/hadoop/common/KEYS
RUN set -x \
  && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
  && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
  && curl -fSL "$HADOOP_KEY_URL" -o /tmp/hadoop-keys \
  && gpg --import /tmp/hadoop-keys \
  && gpg --verify /tmp/hadoop.tar.gz.asc \
  && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
  && rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV PATH $HADOOP_PREFIX/bin/:$PATH

COPY ./hadoop/core-site.xml /etc/hadoop/core-site.xml


# install hbase

ENV HBASE_VERSION 1.2.6
ENV HBASE_INSTALL_DIR /opt/hbase

RUN mkdir -p ${HBASE_INSTALL_DIR} \
    && curl -L https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz | tar -xz --strip=1 -C ${HBASE_INSTALL_DIR}

COPY ./hbase/hbase-site.xml ${HBASE_INSTALL_DIR}/conf/hbase-site.xml

# Add files.
ADD root/.bashrc /root/.bashrc
ADD root/.gitconfig /root/.gitconfig
ADD root/.scripts /root/.scripts


# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
