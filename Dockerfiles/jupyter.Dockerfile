FROM quay.io/jupyter/base-notebook

USER root

# Install Java, curl, and other dependencies
RUN apt-get update \
    && apt-get install -y openjdk-11-jdk curl \
    && apt-get clean

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Download and install Spark 3.5.1
RUN curl -L https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz -o /tmp/spark-3.5.1-bin-hadoop3.tgz && \
    tar -xzf /tmp/spark-3.5.1-bin-hadoop3.tgz -C /usr/local && \
    mv /usr/local/spark-3.5.1-bin-hadoop3 /usr/local/spark && \
    rm /tmp/spark-3.5.1-bin-hadoop3.tgz

# Copy the spark-defaults.conf file to the Spark configuration directory
COPY Dockerfiles/conf/conf-general/core-site.xml /usr/local/spark/conf/core-site.xml
COPY Dockerfiles/conf/conf-general/hive-site.xml /usr/local/spark/conf/hive-site.xml
COPY Dockerfiles/conf/conf-general/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf

ENV SPARK_CONF_DIR=/usr/local/spark/conf

# Copy the requirements.txt file to the temporary directory and install them
COPY Dockerfiles/conf/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY Dockerfiles/conf/conf-jupyter/sparkbuilder.txt /home/jovyan/work/sparkbuilder.txt


# Download necessary JAR files to the temporary directory
RUN curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar -o /usr/local/spark/jars/aws-java-sdk-bundle-1.12.262.jar && \
    curl -L https://repo1.maven.org/maven2/org/antlr/antlr4-runtime/4.9.3/antlr4-runtime-4.9.3.jar -o /usr/local/spark/jars/antlr4-runtime-4.9.3.jar && \
    curl -L https://repo1.maven.org/maven2/io/delta/delta-contribs_2.12/3.1.0/delta-contribs_2.12-3.1.0.jar -o /usr/local/spark/jars/delta-contribs_2.12-3.1.0.jar && \
    curl -L https://repo1.maven.org/maven2/io/delta/delta-iceberg_2.12/3.1.0/delta-iceberg_2.12-3.1.0.jar -o /usr/local/spark/jars/delta-iceberg_2.12-3.1.0.jar && \
    curl -L https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.1.0/delta-spark_2.12-3.1.0.jar -o /usr/local/spark/jars/delta-spark_2.12-3.1.0.jar && \
    curl -L https://repo1.maven.org/maven2/io/delta/delta-storage/3.1.0/delta-storage-3.1.0.jar -o /usr/local/spark/jars/delta-storage-3.1.0.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar -o /usr/local/spark/jars/hadoop-aws-3.3.4.jar

# Configure Jupyter to start with Jupyter Lab interface
ENV JUPYTER_ENABLE_LAB=yes

# Expose port 8888 for Jupyter Lab
EXPOSE 8888

# Switch back to the notebook user
USER $NB_UID

# Command to start Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token="]