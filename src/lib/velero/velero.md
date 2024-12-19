# velero - backup operator

- [.. HOME](../../../README.md)
- https://gist.github.com/taking/3b2e511dbde79b9d9ab361f9fcbd7003
- https://velero.io/docs/main/file-system-backup/
- https://velero.io/docs/main/backup-reference/#schedule-a-backup
- https://velero.io/docs/main/backup-hooks/ # TODO: fsfreeze
- https://velero.io/docs/main/restore-resource-modifiers/ 
- https://velero.io/docs/main/resource-filtering/
- https://kubernetes.io/docs/concepts/storage/volumes/#local
- https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
- https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner

## velero

``` sh
brew install minio-mc velero
make test_velero

velero schedule create --schedule "@weekly" --exclude-resources=pv --snapshot-volumes=false all
velero schedule describe all
velero schedule get

velero backup create --wait --from-schedule all
velero backup get

velero backup   delete --confirm --all 
velero schedule delete --confirm --all
helm delete -n velero velero
```

## kopia

- https://kopia.io/docs/reference/command-line/common/

```fish
brew install kopia
kubectl -n velero get secret velero-repo-credentials -o jsonpath='{.data.repository-password}' | base64 --decode
set KOPIA_PASSWORD static-passw0rd
set AWS_SECRET_ACCESS_KEY password
set AWS_ACCESS_KEY_ID admin
kopia repository connect s3 --disable-tls --prefix=kopia/db/ \
  --override-username=default --override-hostname=default \
  --endpoint=localhost:30001 \
  --bucket=velero-k3d-local-infra

kopia snapshot list -a --storage-stats
kopia snapshot list --json | jq .[].tags
kopia snapshot verify

kopia repository status -t -s
kopia repository throttle get
kopia repository validate-provider # 31.1s
kopia policy list

kopia blob stats
kopia content stats
kopia content verify
kopia cache info
kopia maintenance info

set snapshot $(kopia manifest list --filter=type:snapshot | head -n1 | awk '{print $1;}')
kopia list -lr $snapshot
kopia restore $snapshot tmp/$snapshot
kopia policy show $snapshot

set file PG_VERSION
kopia restore $snapshot/data/$file tmp/$file && cat tmp/$file

mkdir -p tmp/kopia
kopia repository sync-to filesystem --path=$(PWD)/tmp/kopia
kopia repository disconnect
```
