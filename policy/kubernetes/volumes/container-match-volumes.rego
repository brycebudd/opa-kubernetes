package volumes.allowed_containers_match_volumes

import data.lib.kubernetes
import rego.v1

default allow := false

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
	count(violation) == 0
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_volume_workload
	kubernetes.containers[container]
	some mount in container.volumeMounts
	not container_mount_volume(mount)
	msg := sprintf("The volume mount '%s' in container '%s' does not match any defined volumes for workload '%s'.", [mount.name, container.name, name])
	details := {}
}

container_mount_volume(mount) if {
	kubernetes.volumes[volume]
	mount.name == volume.name
}
