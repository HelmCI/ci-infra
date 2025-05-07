{{- $s := .Release.Store }}
{{- $r := $s.registry }}

global:
  security:
    allowInsecureImages: true
  {{- with $r.hostProxy }} 
  imagePullSecrets:
    - name: imagepullsecret-patcher
  {{- end }}

image: # https://hub.docker.com/r/bitnami/clickhouse/tags
  tag: {{ or $s.v (index $s.ver (or $s.image .Release.Name)) "25.4.2-debian-12-r0" }}
  {{- with $r.hostProxy }} 
  registry: {{ $r.hostProxy }}
  repository: {{ $r.proxy.docker }}/bitnami/clickhouse
  {{- end }}

auth:
  existingSecret: secrets
  existingSecretKey: clickhouse

{{- with or $s.host $s.mon.host }}
nodeSelector: 
  kubernetes.io/hostname: {{ . }}
{{- end }}

shards: 1
replicaCount: 1
keeper: 
  enabled: false

metrics:
  enabled: true

service:
  type: NodePort
  nodePorts:
    http: {{ or $s.port 30123 }}
    postgresql: {{ or $s.portPostgresql 30125 }}
