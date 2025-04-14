{{- $s := .Release.Store }}
{{- $r := $s.registry }}
{{- $repo := print $r.hostProxy "/" $r.proxy.quay_io "/minio" }}

{{- with $r.hostProxy }}
image:
  repository: {{ $repo }}/minio
mcImage:
  repository: {{ $repo }}/mc
imagePullSecrets:
  - name: imagepullsecret-patcher
{{- end }}

rootUser: {{ $s.s3.user }}
rootPassword: {{ $s.s3.password }}
users:

mode: standalone
{{- with $s.host }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - {{ . }}
{{- end }}
persistence:
  size: {{ or $s.size "1G" }}
  annotations:
    "helm.sh/resource-policy": keep
resources:
  requests:
    {{/* memory: 1Gi */}}

service:
  type: NodePort
  nodePort: {{ or $s.port "32000" }}
{{- with $s.portConsole }}
consoleService:
  type: NodePort
  nodePort: {{ . }}
{{- end }}

ingress: &ingress
  enabled: false
  hosts:
    - {{ $s.ingress.host | quote }}
  path: /file/
  ingressClassName: nginx
consoleIngress:
  <<: *ingress
  enabled: true
  path: /minio/(.*)
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/proxy-body-size: 100m # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#custom-max-body-size 413 Request Entity Too Large
environment:
  MINIO_BROWSER_REDIRECT_URL: {{ $s.ingress.url }}/minio/
