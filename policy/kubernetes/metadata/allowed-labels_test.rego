package metadata.allowed_labels_test

import rego.v1
import data.metadata.allowed_labels.allow
import data.metadata.allowed_labels.violations

test_should_allow_deployment_with_required_labels if {
    valid_deployment_labels := {
        "kind": "Deployment", 
        "metadata": {
            "name": "valid-deploy-labels", 
            "labels": {
                "app.kubernetes.io/app": "order", 
                "app.kubernetes.io/instance": "order-abc123", 
                "app.kubernetes.io/version": "v1.2.4", 
                "app.kubernetes.io/component": "order-service", 
                "app.kubernetes.io/part-of": "order", 
                "app.kubernetes.io/managed-by": "Helm"                
            }
        }
    }

    allow with input as valid_deployment_labels
}

test_should_not_allow_with_empty_labels if {
    empty_deployment_labels := {
        "kind": "Deployment", 
        "metadata": {
            "name": "empty-deploy-labels"
        }
    }

    not allow with input as empty_deployment_labels
}

test_should_not_allow_with_missing_required_labels if {
    invalid_deployment_labels := {
        "kind": "Deployment", 
        "metadata": {
            "name": "invalid-deploy-labels", 
            "labels": {
                "app.kubernetes.io/app": "order", 
                "app.kubernetes.io/instance": "order-abc123", 
                "app.kubernetes.io/version": "v1.2.4", 
                "app.kubernetes.io/part-of": "order"               
            }
        }
    }    

    not allow with input as invalid_deployment_labels
}