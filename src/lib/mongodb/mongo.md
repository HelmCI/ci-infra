# mongodb

- [.. HOME](../../../README.md)
- [chart](../../../charts/mongodb/README.md)
- [values template](mongo.tpl)

```sh
kubectl -n db exec -it deployments/mongo -c mongodb -- bash -c 'mongosh mongodb://$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD@localhost --eval "show dbs"'
```
