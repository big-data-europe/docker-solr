FROM ubuntu:trusty

MAINTAINER Juergen Jakobitsch <jakobitschj@semantic-web.at>

RUN apt-get install -y wget unzip software-properties-common vim lsof

RUN  add-apt-repository -y ppa:webupd8team/java
RUN  apt-get update
RUN  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN  apt-get -y install oracle-java8-installer
RUN  apt-get -y install oracle-java8-set-default

RUN /bin/bash -c "source /etc/profile.d/jdk.sh"

RUN rm -f /var/cache/oracle-jdk8-installer/jdk-8u72-linux-x64.tar.gz

ENV SOLR_VERSION="5.4.1"
ENV APPLICATION_ROOT="/usr/local/apache-solr"

RUN mkdir -p $APPLICATION_ROOT 
RUN cd $APPLICATION_ROOT && wget http://www-eu.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
RUN cd $APPLICATION_ROOT && tar zxvf solr-${SOLR_VERSION}.tgz
RUN ln -s $APPLICATION_ROOT/solr-${SOLR_VERSION} /usr/local/apache-solr/current
ENV SOLR_HOME=/usr/local/apache-solr/current
RUN cd $APPLICATION_ROOT && rm -f solr-${SOLR_VERSION}.tgz

#ADD solr-5.4.1.tgz /usr/local/apache-solr/
#RUN ln -s /usr/local/apache-solr/solr-5.4.1 /usr/local/apache-solr/current
#ENV SOLR_HOME="/usr/local/apache-solr/current"
#RUN rm -f /tmp/solr-5.4.1.tgz
