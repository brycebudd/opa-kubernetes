package deployments.allowed_probes_test

import rego.v1
import data.deployments.allowed_probes.allow
import data.deployments.allowed_probes.violations
import data.deployments.deployment_fixture as fixture

test_should_allow_deployment_with_valid_probes if {
    allow with input as fixture.valid_deployment
}

test_should_not_allow_deployment_with_missing_liveness_readiness_probes if {
    not allow with input as fixture.missing_probes
}

test_should_warn_deployment_with_missing_startup_probe if {
    not allow with input as fixture.missing_startup_probe
    violations[{"msg": "Warning: The container 'container' in deployment 'app-missing-startup' does not have a startup probe. Consider adding one to ensure smoother application startup and to prevent premature readiness signals.", "details": {}}] with input as fixture.missing_startup_probe
}

test_should_allow_deployment_when_probe_ports_match_container_ports if {
    allow with input as fixture.valid_deployment
}

test_should_not_allow_deployment_when_startupProbe_ports_do_not_match_container_ports if {
    violations[{"msg": "The startup probe for container 'container' in deployment 'invalid-probe-ports' uses port '999', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_readinessProbe_port_does_not_match_container_ports_exposed if {
    violations[{"msg": "The readiness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_livenessProbe_port_does_not_match_container_ports_exposed if {
    violations[{"msg": "The liveness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}





