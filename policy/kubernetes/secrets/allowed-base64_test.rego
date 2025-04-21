package secrets.allowed_base64_test

import rego.v1
import data.secrets.allowed_base64.allow
import data.secrets.allowed_base64.violations

test_should_allow_with_base64_encoded_secret if {
    valid_secret := {
        "kind": "Secret", 
        "metadata": {
            "name": "valid-secret"
        },
        "data": {
            "key1": "c29tZSBkYXRh",
            "key2": "YW5vdGhlciBkYXRh"
        }
    }

    allow with input as valid_secret
}

test_should_not_allow_with_invalid_base64_encoded_secret if {
    invalid_secret := {
        "kind": "Secret", 
        "metadata": {
            "name": "invalid-secret"
        },
        "data": {
            "key1": "this is not base64",
            "key2": "YW5vdGhlciBkYXRh"
        }
    }

    expected_violation := {
        "msg": "Secret 'invalid-secret' contains an invalid key 'key1' that must be base64 encoded",
        "details": {}
    }

    violations[expected_violation] with input as invalid_secret
}

