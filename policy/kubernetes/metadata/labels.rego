package metadata.allowed_labels

import data.lib.kubernetes
import rego.v1

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
	"app.kubernetes.io/managed-by",
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_label_workload
	not kubernetes.has_labels
	msg := sprintf("The %s '%s' is missing required labels '%v'.", [input.kind, name, required_labels])
	details := {}
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_label_workload
	kubernetes.has_labels
	labels := object.keys(input.metadata.labels)
	missing := required_labels - labels
	missing != set()
	msg := sprintf("The %s '%s' is missing required labels '%v'.", [input.kind, name, missing])
	details := {
		"got": labels,
		"wanted": sprintf("%v", [required_labels]),
	}
}
