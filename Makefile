.PHONY: submit start restart stop status
.SILENT: submit start restart stop status minio spark jupyter rebuild  help beeline hive

# Capture the first argument after the target
file := $(word 2, $(MAKECMDGOALS))

# Submit Spark Jobs
submit:
	docker exec sparkmaster spark-submit /opt/spark/jobs/$(file)

# Docker Power Options
start:
	docker compose up -d
restart:
	docker compose down && docker compose up -d
stop:
	docker compose down
status:
	docker ps
rebuild:
	docker compose down && docker compose up -d --build

# Prevent `make` from treating arguments as targets
%:
	@:

# Open Programs URLs
minio:
	open http://localhost:9001
spark:
	open http://localhost:9090
jupyter:
	open http://localhost:8888
beeline:
	echo 'beeline -u jdbc:hive2://localhost:12000 -n hiveuser -p hivepassword'
hive:
	echo -e 'connection=jdbc:hive2://localhost:12000 \nuser=hiveuser \npassword=hivepassword'
	
# Info 
help:
	echo 'Comandos disponibles:'
	echo '  submit [archivo]: Ejecuta un trabajo de Spark usando el archivo especificado.'
	echo '  start: Inicia todos los servicios de Docker en segundo plano.'
	echo '  restart: Reinicia todos los servicios de Docker.'
	echo '  stop: Detiene todos los servicios de Docker.'
	echo '  status: Muestra el estado de los contenedores Docker en ejecución.'
	echo '  rebuild: Reconstruye las imágenes de Docker y reinicia los servicios.'
	echo '  minio: Abre la interfaz web de MinIO en el navegador.'
	echo '  spark: Abre la interfaz web de Spark en el navegador.'
	echo '  jupyter: Abre la interfaz de Jupyter en el navegador.'
	echo '  beeline: Muestra el comando para conectarse a Hive usando Beeline.'
	echo '  hive: Muestra las credenciales y la URL de conexión para HiveServer2.'