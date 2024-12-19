{{- $s := .Release.Store }}
nameOverride: &name {{ $s.name }}
version: &version {{ default "7.0.12" $s.v }} # https://hub.docker.com/_/mongo/tags
image:
  tag: *version
  registry: {{ $s.registry.host }}/dhub/library
service:
  nodePort: 30002
  type: NodePort
settings:
  rootPassword: {{ $s.mongo.password }}
  rootUsername: admin
useDeploymentWhenNonHA: true
storage:
  requestedSize: 1G
  keepPvc: true
podAnnotations:
  backup.velero.io/backup-volumes: mongodb-volume
  pre.hook.backup.velero.io/command:  '["bash", "-c", "mongosh mongodb://$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD@localhost --eval \"db.fsyncLock()\""]'
  post.hook.backup.velero.io/command: '["bash", "-c", "mongosh mongodb://$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD@localhost --eval \"db.fsyncUnlock()\""]'

{{- with $s.node }}
nodeSelector: 
  kubernetes.io/hostname: {{ . }}
{{- end }}

# TODO: mv to node
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

startupProbe:
  initialDelaySeconds: 4 #10
  periodSeconds: 2 #10
readinessProbe:
  initialDelaySeconds: 1 #30

