package autoscaling.replicas_test

import data.autoscaling.replicas
import rego.v1

test_should_allow_when_minreplicas_less_than_maxreplicas if {
	valid_replicas := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "valid-replicas"},
		"spec": {"minReplicas": 2, "maxReplicas": 8},
	}
	replicas.allow with input as valid_replicas
}

test_should_allow_when_minreplicas_equal_to_maxreplicas if {
	equal_replicas := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "valid-equal"},
		"spec": {"minReplicas": 8, "maxReplicas": 8},
	}
	replicas.allow with input as equal_replicas
}

test_should_allow_non_hpa_resource if {
	deployment := {
		"kind": "Deployment",
		"metadata": {"name": "my-deployment"},
		"spec": {"replicas": 2},
	}
	replicas.allow with input as deployment
}

test_should_not_allow_when_minreplicas_greater_than_maxreplicas if {
	invalid_replicas := {
		"kind": "HorizontalPodAutoscaler",
		"metadata": {"name": "invalid-replicas"},
		"spec": {"minReplicas": 9, "maxReplicas": 8},
	}
	not replicas.allow with input as invalid_replicas
	replicas.violation[{"details": {"got": 9, "wanted": "less than or equal to 8"}, "msg": "The HorizontalPodAutoscaler 'invalid-replicas' cannot have 'minReplicas' greater than 'maxReplicas'"}] with input as invalid_replicas
}

test_should_allow_missing_spec_or_replicas if {
	missing_spec := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-spec"}}
	replicas.allow with input as missing_spec
}

test_should_allow_missing_min_replicas if {
	missing_minreplicas := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-min"}, "spec": {"maxReplicas": 8}}
	replicas.allow with input as missing_minreplicas
}

test_should_allow_missing_max_replicas if {
	missing_maxreplicas := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-max"}, "spec": {"minReplicas": 4}}
	replicas.allow with input as missing_maxreplicas
}
