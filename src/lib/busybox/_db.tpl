{{- $s := .Release.Store }}
Secret:
  metadata:
    name: db
    labels:
      backup: secret
  stringData:
    postgres: {{ $s.db.postgres }}
    oidc: {{ or $s.oidc.password $s.db.postgres }}
