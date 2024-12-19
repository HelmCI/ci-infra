{{- $s := .Release.Store }}
{{- $r := $s.registry }}
{{- $repo := $r.hostProxy }}
{{- $dhub := "" }}
{{- with $repo }}
  {{- $dhub = print $repo "/" $r.proxy.docker "/" }}
{{- end }}
{{- $init := or (getenv "I") $s.init | conv.ToBool }}
{{- $s3 := print "http" (or $s.s3.secure "") "://" (or $s.s3_url $s.s3.url) }}

resources:
  limits:
    memory: 1024Mi # 512Mi
upgradeCRDs: {{ $init }}

{{- with $repo }}
image:
  repository: {{ $dhub }}velero/velero # https://hub.docker.com/r/velero/velero/tags
kubectl:
  image:
    repository: {{ $dhub }}bitnami/kubectl
{{- end }}

initContainers:
  - name: velero-plugin-for-aws
    image: {{ $dhub }}velero/velero-plugin-for-aws:v1.9.2 # https://hub.docker.com/r/velero/velero-plugin-for-aws/tags 
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins        

configuration:
  backupStorageLocation:
  - name: {{ $s.kube }}
    provider: &provider aws
    bucket: velero-{{ $s.kube }}
    accessMode: ReadWrite
    default: true
    config:
      region: &region minio
      s3ForcePathStyle: true
      s3Url: {{ $s3 }}
      publicUrl: {{ or $s.s3.public $s3 }}
  {{- range $k, $v := $s.location }}
    {{- $v := or $v dict }}
  - name: {{ $k }}
    provider: &provider aws
    bucket: velero-{{ $k }}
    accessMode: ReadWrite
    config:
      region: &region minio
      s3ForcePathStyle: true
      s3Url:      {{ or           $v.url $s3 }}
      publicUrl:  {{ or $v.public $v.url $s3 }}
  {{- end }}
  volumeSnapshotLocation:
  - name: *provider
    provider: *provider
    config:
      region: *region

credentials:
  useSecret: true
  secretContents:
    cloud: |
      [default]
      aws_access_key_id     = {{ $s.s3.user }}
      aws_secret_access_key = {{ $s.s3.password }}

deployNodeAgent: true

configMaps:  # See: https://velero.io/docs/v1.13/file-system-backup/
  fs-restore-action-config:
    labels:
      velero.io/plugin-config: ""
      velero.io/pod-volume-restore: RestoreItemAction
    data:
  # The value for "image" can either include a tag or not;
  # if the tag is *not* included, the tag from the main Velero
  # image will automatically be used.
      image: {{ $dhub }}velero/velero-restore-helper #:v1.13.2
      cpuRequest: 200m
      memRequest: 128Mi
      cpuLimit: 200m
      memLimit: 128Mi
      secCtx: |
        capabilities:
          drop:
          - ALL
          add: []
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        runAsUser: 1001
        runAsGroup: 999
  # https://velero.io/docs/v1.14/restore-resource-modifiers/ :
  remove-affinity: &resourceModifier
    labels:
      velero.io/resourceModifierRules: # just any value
    data:
      yml: |
        version: v1
        resourceModifierRules:
        - conditions:
            groupResource: statefulsets.apps
          patches:
          - operation: remove
            path: /spec/template/spec/affinity
        - conditions:
            groupResource: pods
          patches:
          - operation: remove
            path: /spec/affinity
        - conditions:
            groupResource: pvc
          patches:
          - operation: remove
            path: /spec/volumeName 

{{- range $s.nodes }}
  node-{{ . }}:
    <<: *resourceModifier
    data:
      yml: |
        version: v1
        resourceModifierRules:
        - conditions:
            groupResource: persistentvolumeclaims
          patches:
          - operation: remove
            path: /spec/volumeName 
        - conditions:
            groupResource: "*.apps"
          mergePatches:
          - patchData: |
              {"spec":{"template": {"spec":{"nodeSelector":{"kubernetes.io/hostname": "{{ . }}" }}} }}
        - conditions:
            groupResource: pods
          mergePatches:
          - patchData: |
                                   {"spec":{"nodeSelector":{"kubernetes.io/hostname": "{{ . }}" }}}
{{- end }}
