# https://github.com/kubernetes-csi/csi-driver-nfs
{{- $s := .Release.Store }}
raw:
- apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: {{ $s.name }}
  provisioner: nfs.csi.k8s.io
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  mountOptions:
    - nfsvers={{ or $s.nfsvers  $s.nfs.nfsvers }} # 4.2
  parameters:
    server:   {{ or $s.srv      $s.nfs.srv }}
    share:   /{{ or $s.share    $s.nfs.share }}
