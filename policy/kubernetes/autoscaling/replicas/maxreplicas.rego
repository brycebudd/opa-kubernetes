package autoscaling.replicas

import data.lib.kubernetes
import rego.v1

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_hpa
	kubernetes.has_field(input, "spec")
	kubernetes.has_field(input.spec, "maxReplicas")
	input.spec.maxReplicas != 8
	msg := sprintf("HorizontalPodAutoscaler %s has unexpected 'maxReplicas'", [name])
	details := {
		"got": input.spec.maxReplicas,
		"wanted": 8,
	}
}
