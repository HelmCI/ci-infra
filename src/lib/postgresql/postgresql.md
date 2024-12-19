# postgresql

- [.. HOME](../../../README.md)

## debug

```sh
set PGHOST localhost
set PGPORT 30000
set t = tmp/db.sql
set e = $t.restore-err.txt
psql -c "select inet_server_addr()"

pg_dumpall --clean --if-exists --load-via-partition-root --quote-all-identifiers | pv | tee $t | wc -l

echo '\c' | psql 2> >(tee $e)
cat $t | psql 2> >(tee $e)
```
