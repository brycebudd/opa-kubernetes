package jobs.allowed_backoff

import data.lib.kubernetes
import rego.v1

default allow := false

# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
	count(violation) == 0
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_job
	not has_backoff_limit
	msg := sprintf("The job %s must specify a backoff limit", [name])
	details := {}
}

violation contains {"msg": msg, "details": details} if {
	kubernetes.is_job
	has_backoff_limit
	input.spec.backoffLimit < 0
	msg := sprintf("The job %s must specify a backoff limit with a positive value", [name])
	details := {
		"got": input.spec.backoffLimit,
		"wanted": "greater than or equal to zero",
	}
}

has_backoff_limit if {
	kubernetes.has_field(input, "spec")
	kubernetes.has_field(input.spec, "backoffLimit")
}
