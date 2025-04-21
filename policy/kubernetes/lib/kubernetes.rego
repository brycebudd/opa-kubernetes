package lib.kubernetes

import rego.v1

containers[container] if {
    pods[pod]
    all_containers = pod_containers(pod, "containers")
    container = all_containers[_]
}

containers[container] if {
    all_containers = pod_containers(input, "containers")
    container = all_containers[_]
}

get_default(object, field, _default) := output if {
    has_field(object, field)
    output := object[field]
}

get_default(object, field, _default) := output if {
    has_field(object, field) == false
    output := _default
}

has_field(object, field) if {
    object[field]
}

has_field(object, field) if {
    object[field] == false
}

has_field(object, field) := false if {
    not object[field]
    not object[field] == false
}

has_job_template_metadata_labels if {
    has_spec
    has_field(input.spec, "jobTemplate")
    has_field(input.spec.jobTemplate, "spec")
    has_field(input.spec.jobTemplate.spec, "template")
    has_field(input.spec.jobTemplate.spec.template, "metadata")
    has_field(input.spec.jobTemplate.spec.template.metadata, "labels")
}

has_labels if {
    has_metadata
    has_field(input.metadata, "labels")
}

has_metadata if {
    has_field(input, "metadata")
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

has_spec if {
    has_field(input, "spec")
}

has_template_metadata_labels if {
    has_spec
    has_field(input.spec, "template")
    has_field(input.spec.template, "metadata")
    has_field(input.spec.template.metadata, "labels")
}

is_cronjob if {
    input.kind == "CronJob"
}

is_daemonset if {
    input.kind == "DaemonSet"
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

is_label_workload if {
    label_kinds[input.kind]
}

is_pod if {
    input.kind == "Pod"
}

is_secret if {
    input.kind == "Secret"
}

is_service if {
    input.kind == "Service"
}

is_subset(subset, superset) if {
    count(object.keys(subset)) == count([k | k = object.keys(subset)[_]; superset[k] == subset[k]])
}

label_kinds := {"Deployment", "Job", "CronJob", "Service"}

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

split_image(image) := [image, "latest"] if {
    not contains(image, ":")
}

split_image(image) := [image_name, tag] if {
    [image_name, tag] := split(image, ":")
}

template(entity) := template if {
    template := entity.spec.template
}

template(entity) := template if {
    template := entity.spec.jobTemplate.spec.template
}

to_millicores(cpu) := millicores if {
    endswith(cpu, "m")
    millicores := to_number(trim_suffix(cpu, "m"))
}

to_millicores(cpu) := millicores if {
    not endswith(cpu, "m")
    millicores := to_number(cpu) * 1000
}

volumes[volume] if {
    pods[pod]
    volume = pod.spec.volumes[_]
}