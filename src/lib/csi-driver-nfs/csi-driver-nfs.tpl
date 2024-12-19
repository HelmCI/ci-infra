# https://github.com/kubernetes-csi/csi-driver-nfs
image:
    baseRepo: {{ .Release.Store.registry.host }}/k8s
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
