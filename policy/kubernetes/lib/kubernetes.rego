package lib.kubernetes

import rego.v1

is_service if {
    input.kind == "Service"
}

is_deployment if {
    input.kind == "Deployment"
}

is_hpa if {
    input.kind == "HorizontalPodAutoscaler"
}

is_job if {
    input.kind == "Job"
}

is_cronjob if {
    input.kind == "CronJob"
}

is_daemonset if {
    input.kind == "DaemonSet"
}


is_pod if {
    input.kind == "Pod"
}

# has_field returns whether an object has a field
has_field(object, field) if {
	object[field]
}

# False is a tricky special case, as false responses would create an undefined document unless
# they are explicitly tested for
has_field(object, field) if {
	object[field] == false
}

has_field(object, field) := false if {
	not object[field]
	not object[field] == false
}

has_spec if {
	has_field(input, "spec")
}

has_replicas if {
    has_spec
    has_field(input.spec, "minReplicas")
    has_field(input.spec, "maxReplicas")
}

has_selector_matchlabels if {
	has_spec
    has_field(input.spec, "selector")
    has_field(input.spec.selector, "matchLabels")	
}

has_template_metadata_labels if {
	has_spec
	has_field(input.spec, "template")
    has_field(input.spec.template, "metadata")
    has_field(input.spec.template.metadata, "labels")	
}

# get_default returns the value of an object's field or the provided default value.
# It avoids creating an undefined state when trying to access an object attribute that does
# not exist
get_default(object, field, _default) := output if {
	has_field(object, field)
	output := object[field]
}

get_default(object, field, _default) := output if {
	has_field(object, field) == false
	output := _default
}

split_image(image) := [image, "latest"] if {
    not contains(image, ":")
}

split_image(image) := [image_name, tag] if {
    [image_name, tag] := split(image, ":")
}

pod_containers(pod, container_type) = result if {
    container_type == "all"
    keys := {"containers", "initContainers"}
    result = [c | keys[k]; c = pod.spec[k][_]]
    
}

pod_containers(pod, container_type) = result if {
    container_type != "all"
    keys := {container_type}
    result = [c | keys[k]; c = pod.spec[k][_]]
}

containers[container] if {
	pods[pod]
	all_containers = pod_containers(pod, "containers")
	container = all_containers[_]
}

containers[container] if {
	all_containers = pod_containers(input, "containers")
	container = all_containers[_]
}

pods[pod] if {
	is_daemonset
	pod = input.spec.template
}

pods[pod] if {
	is_deployment
	pod = input.spec.template
}

pods[pod] if {
	is_pod
	pod = input
}

volumes[volume] if {
	pods[pod]
	volume = pod.spec.volumes[_]
}

probes[probe] if {
	pods[pod]
	probe := pod.spec.containers[_].livenessProbe
}

probes[probe] if {
	pods[pod]
	probe := pod.spec.containers[_].readinessProbe
}

probes[probe] if {
	pods[pod]
	probe := pod.spec.containers[_].startupProbe
}

# Helper function to check if one object is a subset of another
is_subset(subset, superset) if {
 count(object.keys(subset)) == count([k | k = object.keys(subset)[_]; superset[k] == subset[k]])
}

