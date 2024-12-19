{{- $to := .Release.Store.to }} # example.com
Service:
  metadata:
    name: host
    annotations:
      gd/what: host service for local development
      gd/owner: malex
  spec:
    type: ExternalName
    externalName: {{ $to }}
Ingress:
  metadata:
    name: proxy
    annotations:
      gd/what: default backend for local development
      gd/owner: malex
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"  #important
      nginx.ingress.kubernetes.io/upstream-vhost: {{ $to }} #important
  spec:
    rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: host
              port:
                number: 443
