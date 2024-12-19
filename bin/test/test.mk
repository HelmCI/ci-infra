test_cluster = local-infra

test_quick_start: test_cluster_delete test_cluster_create \
	test_up test_all test_velero

test_sql: test_up_sql test_sql_list_dbs
test_oidc: test_up_sql test_up_ingress test_up_oidc test_oidc_curl
test_minio: test_up_ingress test_up_minio test_minio_static
test_nats: test_up_nats nats-version
test_velero: test_up_velero test_velero_backup test_velero_ls

test_cluster_create:
	@echo -e "Сluster $(test_cluster) will be $(RED)created$(NORMAL)! Press enter to continue ..."; read
	k3d cluster create $(test_cluster) -v "$$PWD:$$PWD@server:0" \
		-p 80:80@loadbalancer -p 30000-30001:30000-30001@server:0 \
		--k3s-arg "--disable=traefik,local-storage,metrics-server@server:0"
	ln -s .env.sample.yml .env.yml ||:
test_cluster_delete:
	@echo -e "Сluster $(test_cluster) will be $(RED)deleted$(NORMAL)! Press enter to continue ..."; read
	k3d cluster delete $(test_cluster) ||:
test_cluster_add_port_30000:
	k3d cluster edit $(test_cluster) --port-add 30000:30000@server:0

test_up:
	helmwave up -t $K
test_up_sql:
	helmwave up -t secret,local-path,sql
test_up_ingress: 
	helmwave up -t ingress
test_up_oidc:
	helmwave up -t oidc
test_up_minio:
	helmwave up -t minio,minio-ingress
test_up_nats:
	helmwave up -t nats
test_up_velero: test_velero_pre_install
	I=1 helmwave up -t velero

test_all: test_oidc_curl test_minio_static

test_sql_list_dbs:
	PGHOST=localhost PGPORT=30000 PGPASSWORD=pass psql -l
test_oidc_curl:
	curl -s http://localhost/auth/realms/master/.well-known/openid-configuration | jq .issuer

test_minio_alias:
	mc alias set $(test_cluster) http://localhost:30001 admin password
test_minio_static: test_minio_alias
	curl -s http://localhost/minio/
	mc mb $(test_cluster)/file ||:
	mc anonymous set download $(test_cluster)/file
	mc cp charts.ini $(test_cluster)/file/
	curl -s http://localhost/file/charts.ini

test_velero_bucket = $(test_cluster)/velero-$K
test_velero_pre_install: test_minio_alias
	mc mb $(test_velero_bucket) ||:
test_velero_ls:
	mc ls -r $(test_velero_bucket)
test_velero_cmd = kubectl -n velero exec -it svc/velero -- /velero
test_velero_backup:
	$(test_velero_cmd) backup-location get
	$(test_velero_cmd) schedule create --schedule "@weekly" \
		--exclude-resources=pv --snapshot-volumes=false all
	$(test_velero_cmd) backup create --wait --from-schedule all
	$(test_velero_cmd) backup get
