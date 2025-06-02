package deployments.allowed_container_labels_test

import data.deployments.allowed_container_labels.allow
import data.deployments.allowed_container_labels.violation
import data.deployments.deployment_fixture as fixture
import rego.v1

test_should_allow_deployment_with_valid_container_labels if {
	allow with input as fixture.valid_deployment
}

test_should_not_allow_deployment_with_invalid_metadata_template_labels if {
	not allow with input as fixture.invalid_deployment
	violation[{"msg": "Warning: The deployment 'app-deployment' has template metadata labels that are not a subset of metadata labels.", "details": {"got": {"app": "app", "tier": "frontending"}, "want": "a subset of {\"app\": \"app\", \"tier\": \"frontend\"}"}}] with input as fixture.invalid_deployment
}

test_should_not_allow_deployment_with_missing_template_labels if {
	not allow with input as fixture.missing_template_labels
	violation[{"msg": "The deployment missing_template_labels is missing template metadata labels.", "details": {}}] with input as fixture.missing_template_labels
}

test_should_not_allow_deployment_with_missing_selector_labels if {
	not allow with input as fixture.missing_selector_labels
	violation[{"msg": "The deployment missing_selector_labels is missing selector match labels.", "details": {}}] with input as fixture.missing_selector_labels
}

test_should_not_allow_deployment_with_invalid_template_selector_labels if {
	not allow with input as fixture.invalid_spec_labels
	violation[{"msg": "The deployment 'invalid_selector_labels' has selector labels that are not a subset of template metadata labels.", "details": {"got": {"app_id": "invalid_selector_labels"}, "want": "a subset of {\"app\": \"invalid_selector_labels\"}"}}] with input as fixture.invalid_spec_labels
}
