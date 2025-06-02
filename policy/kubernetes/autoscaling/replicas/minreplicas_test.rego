package autoscaling.replicas_test

import data.autoscaling.replicas
import rego.v1

test_should_allow_when_minreplicas_equal_one if {
	valid_minreplicas := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "valid-less"},
		"spec": {"minReplicas": 1},
	}

	replicas.allow with input as valid_minreplicas
}

test_should_not_allow_minreplicas_less_than_one if {
	invalid_minreplicas := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "valid-less"},
		"spec": {"minReplicas": 0},
	}

	not replicas.allow with input as invalid_minreplicas
}
