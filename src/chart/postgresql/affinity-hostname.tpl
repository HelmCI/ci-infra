{{- $s := .Release.Store }}
{{- define "affinity" }}
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

{{- with $s.write.host }}              
primary:
    {{- template "affinity" . }}
{{- end }}

{{- with $s.read }}              
  {{- with .host }}              
readReplicas: 
    {{- template "affinity" . }}
  {{- end }}
{{- end }}
