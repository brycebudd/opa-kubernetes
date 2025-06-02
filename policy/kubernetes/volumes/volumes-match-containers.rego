package volumes.allowed_volumes_match_containers

import data.lib.kubernetes
import rego.v1

default allow := false

# All Kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

# Allow if there are no violation
allow if {
	count(violation) == 0
}

# Generate violation for unused volumes
violation contains {"msg": msg, "details": details} if {
	kubernetes.is_volume_workload
	kubernetes.volumes[volume]
	not volume_is_mounted(volume)
	msg := sprintf("The volume '%s' in workload '%s' is not used by any containers.", [volume.name, name])
	details := {}
}

# Helper rule to check if a volume is mounted to any container
volume_is_mounted(volume) if {
	kubernetes.containers[container]
	some mount in container.volumeMounts
	mount.name == volume.name
}
