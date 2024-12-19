{{- $s := .Release.Store }}
{{- $i := $s.ingress }}
raw:
- apiVersion: &apiVersion networking.k8s.io/v1
  kind: &kind Ingress
  metadata:
    name: {{ .Release.Name }}
    annotations: &annotations
      gd/what: proxy to minio static
      gd/owner: malex
  spec:
    ingressClassName: &ingressClassName nginx
    rules:
    - host: &host {{ $i.host }}
      http:
        paths:
{{- range $s.buckets }}
        - path: /{{ . }}/
          pathType: &pathType Prefix
          backend: &backend
            service:
              name: minio
              port:
                number: 9000
{{- end }}

- apiVersion: *apiVersion
  kind: *kind
  metadata:
    name: {{ .Release.Name }}-index
    annotations:
      <<: *annotations
      nginx.ingress.kubernetes.io/rewrite-target: /$1/index.html
  spec:
    ingressClassName: *ingressClassName
    rules:
    - host: *host
      http:
        paths:
{{- range $s.buckets }}
        - path: /({{ . }}.*)/$
          pathType: *pathType
          backend: *backend
{{- end }}
