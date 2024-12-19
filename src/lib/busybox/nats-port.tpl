{{- $s := .Release.Store }}
Service:
  metadata:
    name: {{ .Release.Name }}
    annotations:
      gd/what: nodePort for nats
      gd/owner: malex
  spec:
    type: NodePort
    ports:
      - name: http
        port: 4222
        protocol: TCP
        nodePort: 30222
    selector:
      app.kubernetes.io/name: nats
      app.kubernetes.io/instance: nats
