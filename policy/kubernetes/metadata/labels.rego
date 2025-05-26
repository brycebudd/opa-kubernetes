package metadata.allowed_labels

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violation) == 0
}

required_labels := {
    "app.kubernetes.io/app", 
    "app.kubernetes.io/instance", 
    "app.kubernetes.io/version", 
    "app.kubernetes.io/component", 
    "app.kubernetes.io/part-of", 
    "app.kubernetes.io/managed-by"
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_label_workload
    not kubernetes.has_labels
    msg := sprintf("The %s '%s' is missing required labels '%v'.", [input.kind, name, required_labels])
    additionalDetails := {}
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_label_workload
    kubernetes.has_labels
    labels := object.keys(input.metadata.labels)
    missing := required_labels - labels
    missing != set()
    msg := sprintf("The %s '%s' is missing required labels '%v'.", [input.kind, name, missing])
    additionalDetails := {
        "got": labels, 
        "wanted": sprintf("%v", [required_labels])
    }
}

