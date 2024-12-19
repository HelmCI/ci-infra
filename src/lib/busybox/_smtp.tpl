{{- $s := .Release.Store }}
Secret:
  metadata:
    name: smtp
    labels:
      backup: secret
  stringData:
    user: {{ or $s.smtp.user "dev" }}
    password: {{ $s.smtp.password }}
