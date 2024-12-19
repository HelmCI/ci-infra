{{- $r := .Release.Store.registry }}
image:
  {{/* tag: v{{ or .Release.Store.v "0.14" }} */}}
  repository: {{ $r.hostProxy }}/{{ $r.proxy.quay }}/titansoft/imagepullsecret-patcher

conf:
  service_accounts: [default]
  all_service_accounts: false
  imageCredentials:
    registry: {{ $r.hostProxy }}
    username: {{ $r.user }}
    password: {{ $r.password }}
