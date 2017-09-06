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
  && apt-get install --no-install-recommends --no-install-suggests -y \
                      nginx=${NGINX_VERSION} \
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
