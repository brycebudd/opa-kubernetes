package jobs.allowed_backoff

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violations) == 0
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_job
    not has_backoff_limit
    msg := sprintf("The job %s must specify a backoff limit", [name])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_job
    has_backoff_limit
    input.spec.backoffLimit < 0
    msg := sprintf("The job %s must specify a backoff limit with a positive value", [name])
    additionalDetails := {
        "got": input.spec.backoffLimit, 
        "wanted": "greater than or equal to zero"
    }
}

has_backoff_limit if {
    kubernetes.has_field(input, "spec")
    kubernetes.has_field(input.spec, "backoffLimit")
}

