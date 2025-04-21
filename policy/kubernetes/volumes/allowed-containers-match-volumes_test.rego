package volumes.allowed_containers_match_volumes_test

import rego.v1
import data.volumes.allowed_containers_match_volumes.allow
import data.volumes.allowed_containers_match_volumes.violations
import data.volumes.volume_fixture as fixture

test_should_allow_valid_container_volume_mounts if {
    allow with input as fixture.valid_volumes
}

test_should_not_allow_container_volume_mount_without_volume if {
    not allow with input as fixture.invalid_volumes
    violations[{"msg": "The volume mount 'volume3' in container 'container3' does not match any defined volumes for workload 'invalid-volumes'.", "details": {}}] with input as fixture.invalid_volumes
}


