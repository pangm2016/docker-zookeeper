FROM ubuntu:14.04

MAINTAINER pangm "pangm@asto-inc.com" 2016.07.26

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y telnet wget

ADD locale /etc/default/

RUN locale-gen en_US.UTF-8 && \
   DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
ENV locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN (wget --progress=dot --no-check-certificate -O /tmp/jdk-7u79-linux-x64.tar.gz --header "Cookie: oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz &&\
  echo "9222e097e624800fdd9bfb568169ccad  /tmp/jdk-7u79-linux-x64.tar.gz" | md5sum -c > /dev/null 2>&1 || (echo "ERROR: MD5SUM MISMATCH"; exit 1) &&\
  tar xzf /tmp/jdk-7u79-linux-x64.tar.gz -C /root/&&\
  mv /root/jdk1.7.0_79 /root/jdk1.7 &&\
 rm -f /tmp/jdk-7u79-linux-x64.tar.gz)

ENV JAVA_HOME /root/jdk1.7
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$CATALINA_HOME/lib:$CATALINA_HOME/bin:$JAVA_HOME/bin

ARG MIRROR=http://apache.mirrors.pair.com
ARG VERSION=3.4.8

LABEL name="zookeeper" version=$VERSION

RUN wget -q -O - $MIRROR/zookeeper/zookeeper-$VERSION/zookeeper-$VERSION.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-$VERSION /opt/zookeeper \
    && cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg \
    && mkdir -p /tmp/zookeeper

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper

VOLUME ["/opt/zookeeper/conf", "/tmp/zookeeper"]

ENTRYPOINT ["/opt/zookeeper/bin/zkServer.sh"]
CMD ["start-foreground"] 
