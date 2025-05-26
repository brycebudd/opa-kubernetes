package autoscaling.allowed_maxreplicas

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violation) == 0
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_hpa
    kubernetes.has_field(input, "spec")
    kubernetes.has_field(input.spec, "maxReplicas")
    input.spec.maxReplicas != 8
    msg := sprintf("HorizontalPodAutoscaler %s has unexpected 'maxReplicas'", [name])
    additionalDetails := {
        "got": input.spec.maxReplicas,
        "wanted": 8
    }
}
