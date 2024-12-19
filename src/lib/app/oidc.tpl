# https://www.keycloak.org/getting-started/getting-started-docker
# https://www.keycloak.org/server/containers
{{- $store := .Release.Store }}
{{- $_     := $store._ }}
{{- $r     := $store.registry }}
{{- $s     := $store.oidc }}
nameOverride: oidc
image:
  tag: {{ or $store.v "18.0.2" }}
  repository: quay.io/keycloak/keycloak
  {{- with $r.hostProxy }}
  repository: {{ . }}/{{ $r.proxy.quay }}/keycloak/keycloak
  {{- end }}
strategy:
  type: Recreate
podAnnotations:
  gd/acronym: OpenID Connect
  gd/what: OAuth 2.0
  gd/from: https://github.com/keycloak/keycloak
  gd/home: https://www.keycloak.org
  gd/deps: sql
  gd/owner: malex
  gd/runtime: java
startupProbe: &startupProbe
  httpGet:
    path: /auth/
    port: &port 8080
  initialDelaySeconds: 6
  timeoutSeconds: 1
  periodSeconds: 5
  successThreshold: 1
  failureThreshold: 20
readinessProbe:
  <<: *startupProbe
  httpGet:
    port: *port
    path: /auth/realms/master
    # path: /health/ready
  periodSeconds: 10
  failureThreshold: 3
livenessProbe:
  <<: *startupProbe
  timeoutSeconds: 5
  periodSeconds: 10
  failureThreshold: 3
env:
{{- if $s.route }}
  KC_HTTP_RELATIVE_PATH: /{{ $s.route }} 
{{- end }}
  KC_DB: postgres
  KC_DB_URL: jdbc:postgresql://{{ or .Release.Store.sql "sql1-hl.db" }}/keycloak
  KC_DB_USERNAME: postgres
  KEYCLOAK_ADMIN: admin 
  {{/* KC_HOSTNAME: {{ $s.host }} */}}
  {{/* KC_HEALTH_ENABLED: true */}}
  {{/* KC_METRICS_ENABLED: true */}}

envFrom:
  secret:
    db:
      KC_DB_PASSWORD: postgres
      KEYCLOAK_ADMIN_PASSWORD: postgres
service:
  port: *port
  {{/* annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080" */}}

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: {{ $s.host }}
      paths:
      - path: /{{ $s.route }} {{- if $s.route -}} / {{- end }}
        pathType: Prefix

args: ["start-dev"]
