{{- $s := .Release.Store }}
{{- $r := $s.registry }}

{{- with $r.hostProxy }} 
image:
  tag: 26.0.8-debian-12-r0 # https://hub.docker.com/r/bitnami/keycloak/tags
  tag: 26.0.8-debian-12-r1
  tag: 26.1.0-debian-12-r0
  registry: {{ $r.hostProxy }}
  repository: {{ $r.proxy.docker }}/bitnami/keycloak
{{- end }}

httpRelativePath: /auth/
ingress:
  enabled: true
  hostname: ""
  extraHosts:
    - name: ""
      path: /auth/

postgresql:
  enabled: false
externalDatabase:
  port: 5432
  database: keycloak2
  user: postgres
  password: {{ $s.db.postgres }}
  host: {{ or $s.sql "sql1.db" }}
