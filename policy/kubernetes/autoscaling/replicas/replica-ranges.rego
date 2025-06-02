package autoscaling.replicas

import data.lib.kubernetes
import rego.v1

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_hpa
	kubernetes.has_replicas
	input.spec.minReplicas > input.spec.maxReplicas
	msg := sprintf("The HorizontalPodAutoscaler '%s' cannot have 'minReplicas' greater than 'maxReplicas'", [name])
	details := {
		"got": input.spec.minReplicas,
		"wanted": sprintf("less than or equal to %d", [input.spec.maxReplicas]),
	}
}
