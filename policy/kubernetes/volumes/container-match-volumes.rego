package volumes.allowed_containers_match_volumes

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violation) == 0
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_volume_workload
    kubernetes.containers[container]
    some mount in container.volumeMounts
    not container_mount_volume(mount)
    msg := sprintf("The volume mount '%s' in container '%s' does not match any defined volumes for workload '%s'.", [mount.name, container.name, name])
    additionalDetails := {}
}

container_mount_volume(mount) if {
    kubernetes.volumes[volume]
    mount.name == volume.name
}


