package autoscaling.metrics

import data.lib.kubernetes
import rego.v1

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_hpa
	kubernetes.has_field(input, "spec")
	kubernetes.has_field(input.spec, "metrics")
	kubernetes.metrics.get_cpu_utilization_metrics[metric]
	metric.target.averageUtilization != 70
	msg := sprintf("The HorizontalPodAutoscaler '%s' has an invalid cpu utilization", [name])
	details := {
		"got": metric.target.averageUtilization,
		"want": 70,
	}
}
