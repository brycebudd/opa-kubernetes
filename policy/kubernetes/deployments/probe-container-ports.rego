package deployments.allowed_probe_container_ports

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

	# Check liveness probe port
	container.livenessProbe
	probe := container.livenessProbe
	probe_port := get_probe_port(probe)
	not is_container_port_exposed(container.ports, probe_port)
	msg := sprintf("The liveness probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
	details := {}
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_deployment
	kubernetes.containers[container]

	# Check readiness probe port
	container.readinessProbe
	probe := container.readinessProbe
	probe_port := get_probe_port(probe)
	not is_container_port_exposed(container.ports, probe_port)
	msg := sprintf("The readiness probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
	details := {}
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_deployment
	kubernetes.containers[container]

	# Check startup probe port
	container.startupProbe
	probe := container.startupProbe
	probe_port := get_probe_port(probe)
	not is_container_port_exposed(container.ports, probe_port)
	msg := sprintf("The startup probe for container '%s' in deployment '%s' uses port '%v', which is not exposed in the container's ports.", [container.name, name, probe_port])
	details := {}
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
