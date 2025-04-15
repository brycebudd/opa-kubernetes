package deployments.allowed_container_labels

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violations) == 0
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    not kubernetes.has_selector_matchlabels
    msg := sprintf("The deployment %s is missing selector match labels.", [name])
    additionalDetails := {}
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    not kubernetes.has_template_metadata_labels
    msg := sprintf("The deployment %s is missing template metadata labels.", [name])
    additionalDetails := {}    
}

violations contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_deployment
    kubernetes.has_selector_matchlabels
    kubernetes.has_template_metadata_labels
    matchLabels := input.spec.selector.matchLabels
    templateLabels := input.spec.template.metadata.labels
    not kubernetes.is_subset(matchLabels, templateLabels)
    msg := sprintf("The deployment '%s' has selector labels that are not a subset of template metadata labels.", [name])
    additionalDetails := {
        "got": matchLabels, 
        "want": sprintf("a subset of %v", [templateLabels])
    }
}

# Avoid Overlapping Selectors: Ensure that the selectors of different controllers or services don't unintentionally 
# overlap and target the same Pods if that's not the desired behavior.
