package autoscaling.replicas

import rego.v1

default allow := false

allow if {
	count(violation) == 0
}
