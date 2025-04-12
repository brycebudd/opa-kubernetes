package autoscaling.allowed_cpu_utilization

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violations) == 0
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_hpa
    kubernetes.has_field(input, "spec")
    kubernetes.has_field(input.spec, "metrics")
    cpu_metrics := kubernetes.metrics.get_cpu_utilization_metrics
    cpu_metrics[_].target.averageUtilization != 70
    msg := sprintf("The HorizontalPodAutoscaler %s has an invalid cpu utilization", [name])
    additionalDetails := {
        "got": cpu_metrics[_].target.averageUtilization, 
        "want": 70
    }
}

