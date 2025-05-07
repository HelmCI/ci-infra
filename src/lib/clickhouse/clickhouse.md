# ClickHouse

- https://clickhouse.com/docs/interfaces/cli

```sh
helmwave up -t clickhouse
PGHOST=localhost PGPORT=30125 PGDATABASE=default PGUSER=default PGPASSWORD=pass psql

curl https://clickhouse.com/ | sh
sudo ./clickhouse install
clickhouse-client --host localhost --port 30123 --password pass
```
