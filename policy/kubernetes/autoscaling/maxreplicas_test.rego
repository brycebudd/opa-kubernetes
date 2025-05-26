package autoscaling.allowed_maxreplicas_test

import rego.v1
import data.autoscaling.allowed_maxreplicas.allow
import data.autoscaling.allowed_maxreplicas.violation

test_should_allow_when_maxreplicas_equal_eight if {
    valid_maxreplicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {"maxReplicas": 8}
    } 
    
    allow with input as valid_maxreplicas
}

test_should_not_allow_maxreplicas_not_equal_to_eight if {
    invalid_maxreplicas := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {"maxReplicas": 10}
    } 
    
    not allow with input as invalid_maxreplicas
}