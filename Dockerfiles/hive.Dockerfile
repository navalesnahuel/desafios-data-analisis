# Use a base image with Java 8 installed
FROM openjdk:8-jdk

# Install necessary tools
RUN apt-get update && \
    apt-get install -y wget curl procps postgresql-client && \
    apt-get clean

ENV HIVE_VERSION=4.0.0
ENV HADOOP_VERSION=3.3.6
ENV POSTGRESQL_JAR_VERSION=42.2.23
ENV HADOOP_AWS_JAR_VERSION=3.3.4

# Download and extract Hive
RUN wget https://downloads.apache.org/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    tar -xzvf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
    mv apache-hive-${HIVE_VERSION}-bin /opt/hive && \
    rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Download PostgreSQL JDBC driver
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.26/mysql-connector-java-8.0.26.jar -O /opt/hive/lib/mysql-connector-java.jar

# Download Hadoop
RUN curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zx

# Set Hive and Hadoop environment variables
ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HIVE_HOME/bin
ENV HADOOP_HOME=/hadoop-${HADOOP_VERSION}
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV HADOOP_HEAPSIZE=512
ENV MYSQL_HOST: mysql
ENV MYSQL_USER: hiveuser
ENV MYSQL_DB: metastore
ENV MYSQL_PORT: 3306
ENV MYSQL_PASSWORD: hivepassword
ENV DB_TYPE: mysql

# Download additional JAR files
RUN curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_JAR_VERSION}/hadoop-aws-${HADOOP_AWS_JAR_VERSION}.jar --output ${HADOOP_HOME}/share/hadoop/common/lib/hadoop-aws-${HADOOP_AWS_JAR_VERSION}.jar
RUN curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar -o ${HADOOP_HOME}/share/hadoop/common/lib/aws-java-sdk-bundle-1.12.262.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/${HADOOP_VERSION}/hadoop-common-${HADOOP_VERSION}.jar -o ${HADOOP_HOME}/share/hadoop/common/lib/hadoop-common-${HADOOP_VERSION}.jar
RUN curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-exec/${HIVE_VERSION}/hive-exec-${HIVE_VERSION}.jar -o /opt/hive/lib/hive-exec-${HIVE_VERSION}.jar

# Copy hive-site.xml and entrypoint.sh
COPY Dockerfiles/conf/conf-general/hive-site.xml ${HIVE_HOME}/conf/

COPY Dockerfiles/conf/conf-hive/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the necessary ports
EXPOSE 10000 10002 9083

CMD ["/entrypoint.sh"]