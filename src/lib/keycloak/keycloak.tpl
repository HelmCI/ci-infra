# https://artifacthub.io/packages/helm/bitnami/keycloak 
{{- $_              := .Release.Store.__ }}
{{- $file_theme     := "theme.properties" }}
{{- $file_logo      := "logo.png" }}
{{- $ru             := "keycloak/themes/ru" }}
{{- $account        := print $ru      "/account" }}
{{- $account_public := print $account "/resources/public" }}
{{- $account_theme  := print $_ "/" $account        "/" $file_theme }}
{{- $account_logo   := print $_ "/" $account_public "/" $file_logo }}
{{- $s              := .Release.Store.oidc }}
{{- $r              := .Release.Store.registry }}
commonAnnotations:
  sha1/account_theme: {{ file.Read $account_theme | crypto.SHA1 }}
  sha1/account_logo:  {{ file.Read $account_logo  | crypto.SHA1 }}
{{/* httpRelativePath: "/keycloak/" */}}
image:
  registry: {{ $r.hostProxy }}
  repository: {{ $r.proxy.docker }}/bitnami/keycloak
service:
  type: ClusterIP
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  pathType: Prefix
  {{/* path: /keycloak/ */}}
  hostname: {{ $s.host }}
postgresql:
  enabled: false
externalDatabase:
  {{/* host: {{ (.Release.Store.db_map.name | get .Release.Store.db_map.default).wmd }}.db */}}
  host: {{ .Release.Store.sql }}
  port: 5432
  database: keycloak
  user: postgres
  password: {{ .Release.Store.db.postgres }}
auth:
  adminPassword: "WhDzRgkyO4"
  managementPassword: "wfiJZljWwC"
extraVolumes:
  - name: oidc-ru
    configMap:
      name: oidc-ru
extraVolumeMounts:
  - name: oidc-ru
    mountPath: /opt/bitnami/{{ $account }}/{{ $file_theme }}
    subPath: {{ $file_theme }}
    readOnly: true
  - name: oidc-ru
    mountPath: /opt/bitnami/{{ $account_public }}/{{ $file_logo }}
    subPath: {{ $file_logo }}
    readOnly: true
metrics:
  enabled: true
            