package volumes.allowed_volumes_match_containers_test

import rego.v1
import data.volumes.allowed_volumes_match_containers.allow
import data.volumes.allowed_volumes_match_containers.violation
import data.volumes.volume_fixture as fixture

test_should_allow_valid_volumes if {
    allow with input as fixture.valid_volumes
}

test_should_not_allow_volumes_without_container_mount if {
    not allow with input as fixture.invalid_volumes
    violation[{"msg": "The volume 'volume2' in workload 'invalid-volumes' is not used by any containers.", "details": {}}] with input as fixture.invalid_volumes
}

