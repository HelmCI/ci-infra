{{- $s := .Release.Store }}
{{- with $s.write.host }}              
primary: &primary
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
{{- with $s.read }}              
  {{- with .host }}              
readReplicas: *primary
  {{- end }}
{{- end }}