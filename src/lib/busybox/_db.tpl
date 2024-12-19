Secret:
  metadata:
    name: db
    labels:
      backup: secret
  stringData:
    postgres: {{ .Release.Store.db.postgres }}