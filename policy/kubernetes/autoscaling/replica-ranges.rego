package autoscaling.allowed_replica_ranges

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
    kubernetes.has_replicas
    input.spec.minReplicas > input.spec.maxReplicas
    msg := sprintf("The HorizontalPodAutoscaler '%s' cannot have 'minReplicas' greater than 'maxReplicas'", [name])
    additionalDetails := {
        "got": input.spec.minReplicas,
        "wanted": sprintf("less than or equal to %d", [input.spec.maxReplicas])
    }    
}


