package volumes.allowed_containers_match_volumes_test

import data.volumes.allowed_containers_match_volumes.allow
import data.volumes.allowed_containers_match_volumes.violation
import data.volumes.volume_fixture as fixture
import rego.v1

test_should_allow_valid_container_volume_mounts if {
	allow with input as fixture.valid_volumes
}

test_should_not_allow_container_volume_mount_without_volume if {
	not allow with input as fixture.invalid_volumes
	violation[{"msg": "The volume mount 'volume3' in container 'container3' does not match any defined volumes for workload 'invalid-volumes'.", "details": {}}] with input as fixture.invalid_volumes
}
