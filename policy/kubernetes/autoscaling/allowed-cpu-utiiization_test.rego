package autoscaling

import rego.v1

test_should_allow_when_valid_cpu_utilization if {
    valid_cpu_utilization := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {
            "metrics": [
                {"type": "Resource", 
                "resource": {"name": "cpu", "target": {"type": "Utilization", "averageUtilization": 70}}
                }]
        }
    } 

    allow with input as valid_cpu_utilization    
}

test_should_not_allow_when_cpu_utilization_not_equal_seventy if {
    invalid_cpu_utilization := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"},
        "spec": {
            "metrics": [
                {"type": "Resource", 
                "resource": {"name": "cpu", "target": {"type": "Utilization", "averageUtilization": 50}}
                }]
        }
    } 

    not allow with input as invalid_cpu_utilization
    violation[{"details": {"got": 50, "want": 70}, "msg": "The HorizontalPodAutoscaler valid-less has an invalid cpu utilization"}] with input as invalid_cpu_utilization
}

test_should_handle_missing_spec_or_metrics if {
    missing_metrics := {
        "kind": "HorizontalPodAutoscaler",
        "metadata": {"name": "valid-less"}
    } 

    allow with input as missing_metrics    
}
