{{- $s := .Release.Store }}
{{- $r := $s.registry }}
{{- $repo := print $r.hostProxy "/" $r.proxy.docker }}

exporter:
  image:
    tag: 0.12.0 # TODO: 0.15.0 https://hub.docker.com/r/natsio/prometheus-nats-exporter/tags
{{- with $r.hostProxy }}
    registry: {{ $repo }}
nats:
  image:
    registry: {{ $repo }}
    repository: library/nats
{{- end }}

natsbox:
  enabled: {{ or $s.natsbox false }}
reloader:
  enabled: false
