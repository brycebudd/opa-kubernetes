package deployments.allowed_probes

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violations) == 0
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.livenessProbe
    msg := sprintf("The container '%s' in deployment '%s' does not contain a liveness probe.", [container.name, name])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.readinessProbe
    msg := sprintf("The container '%s' in deployment '%s' does not contain a readiness probe.", [container.name, name])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]
    not container.startupProbe
    msg := sprintf("Warning: The container '%s' in deployment '%s' does not have a startup probe. Consider adding one to ensure smoother application startup and to prevent premature readiness signals.", [container.name, name])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]

    # Check liveness probe port
    container.livenessProbe
    probe := container.livenessProbe
    probe_port := get_probe_port(probe)
    not is_container_port_exposed(container.ports, probe_port)
    msg := sprintf("The liveness probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]

    # Check readiness probe port
    container.readinessProbe
    probe := container.readinessProbe
    probe_port := get_probe_port(probe)
    not is_container_port_exposed(container.ports, probe_port)
    msg := sprintf("The readiness probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.containers[container]

    # Check startup probe port
    container.startupProbe
    probe := container.startupProbe
    probe_port := get_probe_port(probe)
    not is_container_port_exposed(container.ports, probe_port)
    msg := sprintf("The startup probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
    additionalDetails := {}
}

# Helper function to extract the port from a probe
get_probe_port(probe) = port if {
    probe.httpGet.port
    port := probe.httpGet.port
}

get_probe_port(probe) = port if {
    probe.tcpSocket.port
    port := probe.tcpSocket.port
}

# Helper function to check if a port is exposed in the container's ports
is_container_port_exposed(container_ports, probe_port) if {
    some port in container_ports
    port.containerPort == probe_port
}
