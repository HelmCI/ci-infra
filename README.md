# HelmwaveCI module - base Infrastructure

Base on [core](https://github.com/HelmCI/ci) ["sub"](ci/README.md) module with [helmwave](https://github.com/helmwave/helmwave) [engine](https://github.com/HelmCI/ci/blob/main/helmwave/helmwave.tpl).

## quick start 

```sh
brew install minio-mc velero curl make git
git submodule update --init

make test_quick_start # 2.6m

# OR:
k3d cluster delete local-infra ||: # 606ms
k3d cluster create local-infra -v "$PWD:$PWD@server:0" \
-p 80:80@loadbalancer -p 443:443@loadbalancer -p 30000-30001:30000-30001@server:0 \
--k3s-arg "--disable=traefik,local-storage,metrics-server@server:0" # 13.3s
ln -s .env.sample.yml .env.yml ||:
helmwave up -t k3d-local-infra # 2.2m
k3d cluster stop  local-infra # 20.6s
k3d cluster start local-infra # 12.1s

# OR:
make test_cluster_create # 13.3s
make test_sql      # 52.8s
make test_oidc     # 26.5s
make test_keycloak # 50s
make test_minio
make test_nats
make test_velero
```

## docs

- [ingress-nginx](src/lib/ingress-nginx/ingress.md)
- [csi-driver-nfs](src/lib/csi-driver-nfs/csi-driver-nfs.md)
- [postgresql](src/lib/postgresql/postgresql.md)
- [keycloak](src/lib/app/oidc.md)
- [keycloak - bitnami](src/lib/keycloak/keycloak.md)
- [mongodb](src/lib/mongodb/mongo.md)
- [nats](src/lib/nats/nats.tpl)
- [velero](src/lib/velero/velero.md)
- [clickhouse](src/lib/clickhouse/clickhouse.md)

## values template

- [imagepullsecret-patcher](src/lib/imagepullsecret-patcher/pull.tpl)
- [local-path-provisioner](src/lib/local-path-provisioner/local-path.tpl)
- [minio](src/lib/minio/minio.tpl)
