{{- $store := .Release.Store }}
{{- $r     := $store.registry }}
{{- $repo := $r.hostProxy }}
{{- $dhub := print $repo "/" $r.proxy.docker }}
{{- $w := $store.write }}
{{- $r := $store.read  }}

{{- define "conf" }}
  {{- range (or .conf coll.Slice | prepend "all") }}
{{ path.Join $._.Release.Store.__ "sql" (print . ".conf") | readFile | indent 4 }}
  {{- end }}
{{- end }}

{{- $ci := dict }}
{{- $file := ".gitlab/images/postgresql.ci.yml" }}
{{- if file.Exists $file }}
  {{- $ci := (index (readFile $file | fromYaml) ".image-postgresql").variables }}
{{- end }}

image:
  tag: {{ or $store.v "15.5.0-debian-11-r25" }} # https://hub.docker.com/r/bitnami/postgresql/tags
  {{/* tag: {{ or $store.v $ci.VER }} */}} # TODO: up all dbs

{{- with $repo }}
  registry: {{ . }}
  repository: ci/{{ or $ci.NAME "postgresql" }}
global: 
  {{/* imageRegistry: {{ $repo }} */}}
  imagePullSecrets:
    - name: imagepullsecret-patcher
{{- end }}

fullnameOverride: {{ .Release.Name }}
auth:
  existingSecret: "db"
  secretKeys:
    adminPasswordKey: postgres
    replicationPasswordKey: postgres
  database: {{ or $store.db.name "postgres" }}
metrics:
  enabled: true
  {{- with $repo }}
  image:
    registry: {{ $dhub }}
  {{- end }}

primary:  
  {{/* persistence: &keep
    annotations:
      helm.sh/resource-policy: keep */}}
  podAnnotations:
    backup.velero.io/backup-volumes: data
  resourcesPreset: none # none, nano, micro, small, medium, large, xlarge, 2xlarge
  service:
    type: NodePort
    nodePorts:
      postgresql: {{ $w.port }}          
  extendedConfiguration: |-
{{ template "conf" (dict "_" $ "conf" $w.conf) }}
{{- if not $w.create }}
  pgHbaConfiguration: |- # disable for first run :(
    # TYPE DATABASE    USER ADDRESS     METHOD
    local  all         all              md5
    host   replication all  0.0.0.0/0   md5
    host   all         sub  10.0.0.0/8  trust
    host   all         all  0.0.0.0/0   md5
{{- end }}

{{- if $r}}              
architecture: replication
readReplicas:
  {{/* persistence: *keep */}}
  resourcesPreset: none
  replicaCount: {{ or $r.count 1 }}
  service:
    type: NodePort
    nodePorts:
      postgresql: {{ $r.port }}  
  extendedConfiguration: |-
{{ template "conf" (dict "_" $ "conf" $r.conf) }}
{{- end }}
