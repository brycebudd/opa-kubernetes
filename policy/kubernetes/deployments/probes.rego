package deployments.allowed_probes

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violation) == 0
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.livenessProbe
    msg := sprintf("The container '%s' in deployment '%s' does not contain a liveness probe.", [container.name, name])
    additionalDetails := {}
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.readinessProbe
    msg := sprintf("The container '%s' in deployment '%s' does not contain a readiness probe.", [container.name, name])
    additionalDetails := {}
}

warn contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.startupProbe
    msg := sprintf("The container '%s' in deployment '%s' does not have a startup probe. Consider adding one to ensure smoother application startup and to prevent premature readiness signals.", [container.name, name])
    additionalDetails := {}
}
