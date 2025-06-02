package deployments.allowed_probe_container_ports_test

import data.deployments.allowed_probe_container_ports.violation
import data.deployments.deployment_fixture as fixture
import rego.v1

test_should_not_allow_deployment_when_startupProbe_ports_do_not_match_container_ports if {
	violation[{"msg": "The startup probe for container 'container' in deployment 'invalid-probe-ports' uses port '999', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_readinessProbe_port_does_not_match_container_ports_exposed if {
	violation[{"msg": "The readiness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}

test_should_not_allow_deployment_when_livenessProbe_port_does_not_match_container_ports_exposed if {
	violation[{"msg": "The liveness probe for container 'container' in deployment 'invalid-probe-ports' uses port '80', which is not exposed in the container's ports.", "details": {}}] with input as fixture.invalid_probe_ports
}
