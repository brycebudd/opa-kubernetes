package deployments.allowed_probes

import data.lib.kubernetes
import rego.v1

default allow := false

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
	count(violation) == 0
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_deployment
	kubernetes.containers[container]
	not container.livenessProbe
	msg := sprintf("The container '%s' in deployment '%s' does not contain a liveness probe.", [container.name, name])
	details := {}
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_deployment
	kubernetes.containers[container]
	not container.readinessProbe
	msg := sprintf("The container '%s' in deployment '%s' does not contain a readiness probe.", [container.name, name])
	details := {}
}

warn contains {"msg": msg, "details": details} if {
	kubernetes.is_deployment
	kubernetes.containers[container]
	not container.startupProbe
	msg := sprintf("The container '%s' in deployment '%s' does not have a startup probe. Consider adding one to ensure smoother application startup and to prevent premature readiness signals.", [container.name, name])
	details := {}
}
