package secrets.allowed_base64

import rego.v1
import data.lib.kubernetes

default allow := false
# all kubernetes resources must have a name
name := kubernetes.get_default(input.metadata, "name", "default")

allow if {
    count(violation) == 0
}

violation contains {"msg": msg, "details": additionalDetails} if {
    kubernetes.is_secret
    some key
    encoded_value := input.data[key]
    not base64.is_valid(encoded_value)
    msg := sprintf("Secret '%s' contains an invalid key '%s' that must be base64 encoded", [name, key])
    additionalDetails := {}
}

