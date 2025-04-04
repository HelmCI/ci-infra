{{- $s := .Release.Store }}
Secret:
  metadata:
    name: ssl
    labels:
      backup: secret
  stringData:
    tls.crt: |
{{ $s.ssl.crt | indent 6 }}
    tls.key: |
{{ $s.ssl.key | indent 6 }}
