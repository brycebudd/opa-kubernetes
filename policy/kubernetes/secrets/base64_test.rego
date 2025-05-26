package secrets.allowed_base64_test

import rego.v1
import data.secrets.allowed_base64.allow
import data.secrets.allowed_base64.violation

test_should_allow_with_base64_encoded_secret if {
    valid_secret := {
        "kind": "Secret", 
        "metadata": {
            "name": "valid-secret"
        },
        "data": {
            "key1": "dGhpcyBpcyBiYXNlNjQgZW5jb2RlZA==",
            "key2": "dGhpcyBpcyB0aGUgdmFsdWUgb2Yga2V5IDI="
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
            "key2": "dGhpcyBpcyB0aGUgdmFsdWUgb2Yga2V5IDI="
        }
    }

    expected_violation := {
        "msg": "Secret 'invalid-secret' contains an invalid key 'key1' that must be base64 encoded",
        "details": {}
    }

    violation[expected_violation] with input as invalid_secret
}

test_should_not_allow_with_multiple_invalid_base64_encoded_secret if {
    invalid_secret := {
        "kind": "Secret", 
        "metadata": {
            "name": "invalid-secret"
        },
        "data": {
            "key1": "this is not base64",
            "key2": "dGhpcyBpcyB0aGUgdmFsdWUgb2Yga2V5IDI=",
            "key3": "this is also not base64"
        }
    }

    expected_violations := [{
            "msg": "Secret 'invalid-secret' contains an invalid key 'key1' that must be base64 encoded",
            "details": {}
        },
        {
        "msg": "Secret 'invalid-secret' contains an invalid key 'key3' that must be base64 encoded",
        "details": {}
        }
    ]
    violation[expected_violations[0]] with input as invalid_secret
    violation[expected_violations[1]] with input as invalid_secret
}

