# https://github.com/kubernetes-csi/csi-driver-nfs
{{- $r := .Release.Store.registry }}
{{- with $r.hostProxy }}
image:
    baseRepo: {{ . }}/{{ $r.proxy.k8s }}
    nfs:
        repository: /sig-storage/nfsplugin
    csiProvisioner:
        repository: /sig-storage/csi-provisioner
    csiSnapshotter:
        repository: /sig-storage/csi-snapshotter
    livenessProbe:
        repository: /sig-storage/livenessprobe
    nodeDriverRegistrar:
        repository: /sig-storage/csi-node-driver-registrar
    externalSnapshotter:
        repository: /sig-storage/snapshot-controller
{{- end }}
