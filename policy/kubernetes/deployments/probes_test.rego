package deployments.allowed_probes_test

import rego.v1
import data.deployments.allowed_probes.allow
import data.deployments.allowed_probes.violation
import data.deployments.allowed_probes.warn
import data.deployments.deployment_fixture as fixture

test_should_allow_deployment_with_valid_probes if {
    allow with input as fixture.valid_deployment
}

test_should_not_allow_deployment_with_missing_liveness_readiness_probes if {
    not allow with input as fixture.missing_probes
}

test_should_warn_deployment_with_missing_startup_probe if {
    warn[{"msg": "The container 'container' in deployment 'app-missing-startup' does not have a startup probe. Consider adding one to ensure smoother application startup and to prevent premature readiness signals.", "details": {}}] with input as fixture.missing_startup_probe
}

test_should_allow_deployment_when_probe_ports_match_container_ports if {
    allow with input as fixture.valid_deployment
}





