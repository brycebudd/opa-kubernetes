package deployments.allowed_probe_container_ports_test

import rego.v1
import data.deployments.allowed_probe_container_ports.violations
import data.deployments.deployment_fixture as fixture

test_should_not_allow_deployment_when_startupProbe_ports_do_not_match_container_ports if {
    violations[{"msg": "The startup probe for container 'container' in deployment 'invalid-probe-ports' uses port '999', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_readinessProbe_port_does_not_match_container_ports_exposed if {
    violations[{"msg": "The readiness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_livenessProbe_port_does_not_match_container_ports_exposed if {
    violations[{"msg": "The liveness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}