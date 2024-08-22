#!/bin/sh

# Initialize the Hive schema if not already done
echo "Initializing Hive schema..."
schematool -dbType ${DB_TYPE} -initSchema --verbose

# Start Hive Metastore
echo "Starting Hive Metastore..."
hive --service metastore 

# Keep the container running
exec "$@"
