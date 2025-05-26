package autoscaling.allowed_minreplicas_test

import rego.v1
import data.autoscaling.allowed_minreplicas.allow
import data.autoscaling.allowed_minreplicas.violation

test_should_allow_when_minreplicas_equal_one if {
    valid_minreplicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {"minReplicas": 1}
    } 
    
    allow with input as valid_minreplicas
}

test_should_not_allow_minreplicas_greater_than_one if {
    invalid_minreplicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {"minReplicas": 5}
    } 
    
    not allow with input as invalid_minreplicas
}