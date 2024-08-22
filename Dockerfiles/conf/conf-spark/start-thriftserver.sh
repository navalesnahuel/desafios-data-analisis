# start-thriftserver.sh
#!/bin/sh

/opt/bitnami/spark/sbin/start-thriftserver.sh \
  --conf spark.sql.catalogImplementation=hive \
  --conf spark.hadoop.hive.metastore.uris=thrift://hive-metastore:9083
