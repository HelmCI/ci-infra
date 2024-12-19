{{- $s := .Release.Store }}
{{- $r := $s.registry }}
{{- $repo := print $r.hostProxy "/" $r.proxy.docker }}

replicaCount: 1
image:
  tag: v{{ or $s.v "0.0.27" }} # https://hub.docker.com/r/rancher/local-path-provisioner/tags
{{- with $r.hostProxy }}
  repository: {{ $repo }}/rancher/local-path-provisioner
helperImage:
  repository: {{ $repo }}/library/busybox
{{- end }}

nameOverride: {{ .Release.Name }}
storageClass:
  name: local-path
  defaultClass: true
  reclaimPolicy: Retain
  defaultVolumeType: local
  pathPattern: "{{"{{ .PVC.Namespace }}-{{ .PVC.Name }}"}}"

imagePullSecrets:
  - name: imagepullsecret-patcher
