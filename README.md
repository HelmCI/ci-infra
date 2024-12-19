# HelmwaveCI module - base Infrastructure

- [base on core sub module with helmwave engine](ci/README.md)

## quick start 

```sh
brew install minio-mc velero curl make git
git submodule update --init

make test_quick_start # 2.6m

# OR:
k3d cluster delete local-infra ||: # 606ms
k3d cluster create local-infra -v "$PWD:$PWD@server:0" \
-p 80:80@loadbalancer -p 30000-30001:30000-30001@server:0 \
--k3s-arg "--disable=traefik,local-storage,metrics-server@server:0" # 13.3s
ln -s .env.sample.yml .env.yml ||:
helmwave up -t k3d-local-infra # 2.2m
k3d cluster stop  local-infra # 20.6s
k3d cluster start local-infra # 12.1s

# OR:
make test_cluster_create
make test_sql
make test_oidc
make test_minio
make test_nats
make test_velero
```
