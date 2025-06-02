package autoscaling.replicas

import rego.v1
import data.lib.kubernetes

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_hpa
    kubernetes.has_field(input, "spec")
    kubernetes.has_field(input.spec, "minReplicas")
    input.spec.minReplicas < 1
    msg := sprintf("HorizontalPodAutoscaler %s has unexpected 'minReplicas'", [name])
    additionalDetails := {
        "got": input.spec.minReplicas,
        "wanted": 1
    }
}
