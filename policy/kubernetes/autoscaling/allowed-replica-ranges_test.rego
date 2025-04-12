package autoscaling.allowed_replica_ranges_test

import rego.v1
import data.autoscaling.allowed_replica_ranges.allow
import data.autoscaling.allowed_replica_ranges.violations

test_should_allow_when_minreplicas_less_than_maxreplicas if {
    valid_replicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {"minReplicas": 2, "maxReplicas": 5}
    }
    allow with input as valid_replicas
}

test_should_allow_when_minreplicas_equal_to_maxreplicas if {
    equal_replicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-equal"},
        "spec": {"minReplicas": 3, "maxReplicas": 3}
    }
    allow with input as equal_replicas
}

test_should_allow_non_hpa_resource if {
    deployment := {
        "kind": "Deployment",
        "metadata": {"name": "my-deployment"},
        "spec": {"replicas": 2}
    }
    allow with input as deployment
}

test_should_not_allow_when_minreplicas_greater_than_maxreplicas if {
    invalid_replicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "invalid-replicas"},
        "spec": {"minReplicas": 4, "maxReplicas": 3}
    }
    not allow with input as invalid_replicas
    violations[{"details": {"got": 4, "wanted": "less than or equal to 3"}, "msg": "The HorizontalPodAutoscaler 'invalid-replicas' cannot have 'minReplicas' greater than 'maxReplicas'"}] with input as invalid_replicas
}

test_should_handle_missing_spec_or_replicas if {
    missing_spec := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-spec"}}
    allow with input as missing_spec

    missing_minreplicas := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-min"}, "spec": {"maxReplicas": 3}}
    allow with input as missing_minreplicas

    missing_maxreplicas := {"kind": "HorizontalPodAutoscaler", "metadata": {"name": "missing-max"}, "spec": {"minReplicas": 4}}
    allow with input as missing_maxreplicas
}