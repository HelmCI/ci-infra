{{- $s := .Release.Store }}
Secret:
  metadata:
    name: minio-db
  stringData:
    oidc: {{ $s.s3.oidc }}
