{{- $s    := .Release.Store }}
{{- $r    := $s.registry }}
{{- $k8s  := print $r.hostProxy "/" $r.proxy.k8s }}

fullnameOverride: ingress
controller:
  {{- with $s.node }}
  nodeSelector:
    kubernetes.io/hostname: {{ . }}
  {{- end }}

  kind: DaemonSet
  service:
    type: ClusterIP
  hostPort: # https://github.com/kubernetes/kubernetes/issues/23920
    enabled: true
{{- with $s.ports }}
    ports: # https://github.com/kubernetes-sigs/kubespray/issues/4357#issuecomment-508137837
{{ toYAML . | indent 6 }}
{{- end }}

  ingressClassResource:
    default: true
  {{- with $r.hostProxy }}
  image:
    registry: {{ $k8s }}
  {{- end }}
  {{- with $s.v }}
    tag: {{ . }}
    {{- with $s.digest }}
    digest: {{ . }}
    {{- else }}
    digest:
    {{- end }}
  {{- end }}

  config: # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
    proxy-buffer-size: "128k" # fix: upstream sent too big header while reading response header from upstream
    large-client-header-buffers: "4 128k"
{{- with $s.otlp }} # https://github.com/kubernetes/ingress-nginx/pull/9062
    otlp-collector-host: {{ . }}
    enable-opentelemetry: true
  opentelemetry:
    enabled: true
    name: opentelemetry
    {{- with $r.hostProxy }}
    image:
      registry: {{ $k8s }}
    {{- end }}
{{- end }}
  admissionWebhooks:
     enabled: {{ or (getenv "I") .Release.Store.admissionWebhooks false }}
  metrics:
    enabled: true
    service:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "10254"

{{- with $s.extraArgs }}
  extraArgs:
{{ toYAML . | indent 4 }}
{{- end }}
