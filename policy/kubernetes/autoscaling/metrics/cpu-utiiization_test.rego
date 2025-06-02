package autoscaling.metrics_test

import data.autoscaling.metrics
import rego.v1

test_should_allow_when_valid_cpu_utilization if {
	valid_cpu_utilization := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "valid-cpu"},
		"spec": {"metrics": [{
			"type": "Resource",
			"resource": {"name": "cpu", "target": {"type": "Utilization", "averageUtilization": 70}},
		}]},
	}

	metrics.allow with input as valid_cpu_utilization
}

test_should_not_allow_when_cpu_utilization_not_equal_seventy if {
	invalid_cpu_utilization := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "invalid-cpu"},
		"spec": {"metrics": [{
			"type": "Resource",
			"resource": {"name": "cpu", "target": {"type": "Utilization", "averageUtilization": 50}},
		}]},
	}

	not metrics.allow with input as invalid_cpu_utilization
	metrics.violation[{"msg": "The HorizontalPodAutoscaler 'invalid-cpu' has an invalid cpu utilization", "details": {"got": 50, "want": 70}}] with input as invalid_cpu_utilization
}

test_should_handle_missing_spec_or_metrics if {
	missing_metrics := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "missing-metrics"},
	}

	metrics.allow with input as missing_metrics
}
