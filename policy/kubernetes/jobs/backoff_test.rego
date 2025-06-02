package jobs.allowed_backoff_test

import data.jobs.allowed_backoff.allow
import data.jobs.allowed_backoff.violation
import rego.v1

test_should_allow_job_with_backoff_limit if {
	valid_job := {
		"kind": "Job",
		"metadata": {"name": "valid-job"},
		"spec": {"backoffLimit": 10},
	}

	allow with input as valid_job
}

test_should_not_allow_job_with_missing_backoff_limit if {
	missing_backoff := {
		"kind": "Job",
		"metadata": {"name": "missing-backoff"},
	}

	not allow with input as missing_backoff
}

test_should_not_allow_job_with_negative_backoff_limit if {
	negative_backoff := {
		"kind": "Job",
		"metadata": {"name": "negative-backoff"},
		"spec": {"backoffLimit": -1},
	}

	not allow with input as negative_backoff
}
