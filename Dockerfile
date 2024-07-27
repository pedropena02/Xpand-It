FROM centos:centos7

#Add a specific mirror directly to the Yum repositories file
RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo && \ 
    sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo  

#update packets and install dependencies 
RUN yum clean all && \  
    yum -y update && \
    yum -y install wget tar java-11-openjdk-devel openssl

ENV JAVA_VERSION 11

#tomcat information 
ENV CATALINA_HOME /opt/tomcat
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.73


#install tomcat
RUN wget "http://ftp.unicamp.br/pub/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} ${CATALINA_HOME}


#install sample application
RUN wget https://tomcat.apache.org/tomcat-8.5-doc/appdev/sample/sample.war -P ${CATALINA_HOME}/webapps/

#add certificate and private key 
ADD server.crt ${CATALINA_HOME}/conf/
ADD server.key ${CATALINA_HOME}/conf/

# Create PKCS12 keystore
RUN openssl pkcs12 -export -out ${CATALINA_HOME}/conf/keystore.p12 \
    -inkey ${CATALINA_HOME}/conf/server.key -in ${CATALINA_HOME}/conf/server.crt \
    -passout pass:changeit -name tomcat && \
    rm ${CATALINA_HOME}/conf/server.key ${CATALINA_HOME}/conf/server.crt  

#tomcat ssl configuration
RUN sed -i '/<\/Service>/i \
    <Connector \
          protocol="org.apache.coyote.http11.Http11NioProtocol" \
          port="4041" \
          maxThreads="200" \
          maxParameterCount="1000" \
          scheme="https" \
          secure="true" \
          SSLEnabled="true" \
          keystoreFile="/opt/tomcat/conf/keystore.p12" \
          keystoreType="PKCS12" \
          keystorePass="changeit" \
          clientAuth="false" \
          sslProtocol="TLS"/>' ${CATALINA_HOME}/conf/server.xml

#Expose Port
EXPOSE 4041

#Command to start tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]