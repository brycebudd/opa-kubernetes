package deployments.deployment_fixture

valid_deployment := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "app-deployment",
		"namespace": "default",
		"labels": {
			"app": "app",
			"tier": "frontend",
		},
		"annotations": {
			"description": "This is a sample deployment for testing Rego policies.",
			"owner": "team-a",
		},
	},
	"spec": {
		"replicas": 3,
		"selector": {"matchLabels": {"app": "app"}},
		"strategy": {
			"type": "RollingUpdate",
			"rollingUpdate": {
				"maxUnavailable": 1,
				"maxSurge": 2,
			},
		},
		"minReadySeconds": 10,
		"revisionHistoryLimit": 5,
		"paused": false,
		"progressDeadlineSeconds": 600,
		"template": {
			"metadata": {
				"labels": {
					"app": "app",
					"tier": "frontend",
				},
				"annotations": {
					"version": "v1.0.0",
					"build-id": "abcdef12345",
				},
			},
			"spec": {
				"volumes": [
					{
						"name": "data-volume",
						"emptyDir": {},
					},
					{
						"name": "config-volume",
						"configMap": {
							"name": "app-config",
							"items": [{
								"key": "config.yaml",
								"path": "app-config.yaml",
							}],
							"optional": true,
						},
					},
					{
						"name": "secret-volume",
						"secret": {
							"secretName": "app-secret",
							"items": [{
								"key": "api-key",
								"path": "api.key",
							}],
							"optional": true,
						},
					},
					{
						"name": "persistent-volume",
						"persistentVolumeClaim": {"claimName": "pvc"},
					},
				],
				"initContainers": [{
					"name": "init-database",
					"image": "busybox:latest",
					"command": [
						"sh",
						"-c",
						"until nslookup db-service; do echo waiting for database... && sleep 5; done",
					],
					"resources": {
						"limits": {
							"cpu": "100m",
							"memory": "128Mi",
						},
						"requests": {
							"cpu": "50m",
							"memory": "64Mi",
						},
					},
					"volumeMounts": [{
						"name": "data-volume",
						"mountPath": "/data",
					}],
				}],
				"containers": [{
					"name": "app-container",
					"image": "nginx:latest",
					"ports": [{
						"containerPort": 80,
						"name": "http",
						"protocol": "TCP",
					}],
					"env": [
						{
							"name": "DATABASE_URL",
							"valueFrom": {"secretKeyRef": {
								"name": "db-credentials",
								"key": "url",
							}},
						},
						{
							"name": "API_KEY",
							"valueFrom": {"secretKeyRef": {
								"name": "app-secret",
								"key": "api-key",
							}},
						},
						{
							"name": "APP_VERSION",
							"value": "1.0",
						},
					],
					"resources": {
						"limits": {
							"cpu": "500m",
							"memory": "512Mi",
						},
						"requests": {
							"cpu": "100m",
							"memory": "256Mi",
						},
					},
					"livenessProbe": {
						"httpGet": {
							"path": "/healthz",
							"port": 80,
						},
						"initialDelaySeconds": 15,
						"periodSeconds": 10,
						"timeoutSeconds": 5,
						"successThreshold": 1,
						"failureThreshold": 3,
					},
					"readinessProbe": {
						"tcpSocket": {"port": 80},
						"initialDelaySeconds": 5,
						"periodSeconds": 5,
						"timeoutSeconds": 2,
						"successThreshold": 1,
						"failureThreshold": 3,
					},
					"startupProbe": {
						"httpGet": {
							"path": "/startup",
							"port": 80,
						},
						"initialDelaySeconds": 30,
						"periodSeconds": 5,
						"timeoutSeconds": 5,
						"failureThreshold": 6,
					},
					"volumeMounts": [
						{
							"name": "data-volume",
							"mountPath": "/app/data",
						},
						{
							"name": "config-volume",
							"mountPath": "/app/config",
							"readOnly": true,
						},
						{
							"name": "secret-volume",
							"mountPath": "/app/secrets",
							"readOnly": true,
						},
						{
							"name": "persistent-volume",
							"mountPath": "/app/persistent",
						},
					],
					"lifecycle": {
						"postStart": {"exec": {"command": [
							"/bin/sh",
							"-c",
							"echo 'Application started'",
						]}},
						"preStop": {"exec": {"command": [
							"/bin/sh",
							"-c",
							"sleep 5 && echo 'Application stopping'",
						]}},
					},
					"securityContext": {
						"privileged": false,
						"runAsUser": 1000,
						"runAsGroup": 2000,
						"runAsNonRoot": true,
						"seLinuxOptions": {
							"level": "s0:c1,c2",
							"role": "object_r",
							"type": "container_file_t",
						},
						"capabilities": {
							"add": ["NET_BIND_SERVICE"],
							"drop": ["ALL"],
						},
						"readOnlyRootFilesystem": true,
						"allowPrivilegeEscalation": false,
						"procMount": "Default",
					},
				}],
				"affinity": {
					"nodeAffinity": {"requiredDuringSchedulingIgnoredDuringExecution": {"nodeSelectorTerms": [{"matchExpressions": [{
						"key": "kubernetes.io/arch",
						"operator": "In",
						"values": ["amd64"],
					}]}]}},
					"podAffinity": {"preferredDuringSchedulingIgnoredDuringExecution": [{
						"weight": 100,
						"podAffinityTerm": {
							"labelSelector": {"matchLabels": {
								"app": "app",
								"tier": "backend",
							}},
							"topologyKey": "kubernetes.io/hostname",
						},
					}]},
					"podAntiAffinity": {"requiredDuringSchedulingIgnoredDuringExecution": [{
						"labelSelector": {"matchLabels": {"app": "app"}},
						"topologyKey": "topology.kubernetes.io/zone",
					}]},
				},
				"tolerations": [
					{
						"key": "node.kubernetes.io/unreachable",
						"operator": "Exists",
						"effect": "NoExecute",
						"tolerationSeconds": 300,
					},
					{
						"key": "node.kubernetes.io/not-ready",
						"operator": "Exists",
						"effect": "NoExecute",
						"tolerationSeconds": 300,
					},
					{
						"key": "special-node",
						"operator": "Equal",
						"value": "true",
						"effect": "NoSchedule",
					},
				],
				"dnsPolicy": "ClusterFirst",
				"dnsConfig": {
					"nameservers": ["10.0.0.10"],
					"searches": [
						"default.svc.cluster.local",
						"svc.cluster.local",
						"cluster.local",
					],
					"options": [{
						"name": "ndots",
						"value": "5",
					}],
				},
				"serviceAccountName": "app-sa",
				"automountServiceAccountToken": true,
				"shareProcessNamespace": false,
				"terminationGracePeriodSeconds": 30,
				"activeDeadlineSeconds": 600,
				"hostNetwork": false,
				"hostPID": false,
				"hostIPC": false,
				"securityContext": {
					"runAsUser": 1000,
					"runAsGroup": 2000,
					"fsGroup": 3000,
					"supplementalGroups": [
						4000,
						5000,
					],
				},
				"topologySpreadConstraints": [
					{
						"maxSkew": 1,
						"topologyKey": "kubernetes.io/zone",
						"whenUnsatisfiable": "DoNotSchedule",
						"labelSelector": {"matchLabels": {"app": "app"}},
					},
					{
						"maxSkew": 2,
						"topologyKey": "kubernetes.io/hostname",
						"whenUnsatisfiable": "ScheduleAnyway",
						"labelSelector": {"matchLabels": {"app": "app"}},
					},
				],
			},
		},
	},
}

invalid_deployment := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "app-deployment",
		"namespace": "default",
		"labels": {
			"app": "app",
			"tier": "frontend",
		},
		"annotations": {
			"description": "This is a sample deployment for testing Rego policies.",
			"owner": "team-a",
		},
	},
	"spec": {
		"replicas": 3,
		"selector": {"matchLabels": {"app": "app"}},
		"strategy": {
			"type": "RollingUpdate",
			"rollingUpdate": {
				"maxUnavailable": 1,
				"maxSurge": 2,
			},
		},
		"minReadySeconds": 10,
		"revisionHistoryLimit": 5,
		"paused": false,
		"progressDeadlineSeconds": 600,
		"template": {
			"metadata": {
				"labels": {
					"app": "app",
					"tier": "frontending",
				},
				"annotations": {
					"version": "v1.0.0",
					"build-id": "abcdef12345",
				},
			},
			"spec": {
				"volumes": [
					{
						"name": "data-volume",
						"emptyDir": {},
					},
					{
						"name": "config-volume",
						"configMap": {
							"name": "app-config",
							"items": [{
								"key": "config.yaml",
								"path": "app-config.yaml",
							}],
							"optional": true,
						},
					},
					{
						"name": "secret-volume",
						"secret": {
							"secretName": "app-secret",
							"items": [{
								"key": "api-key",
								"path": "api.key",
							}],
							"optional": true,
						},
					},
					{
						"name": "persistent-volume",
						"persistentVolumeClaim": {"claimName": "pvc"},
					},
				],
				"initContainers": [{
					"name": "init-database",
					"image": "busybox:latest",
					"command": [
						"sh",
						"-c",
						"until nslookup db-service; do echo waiting for database... && sleep 5; done",
					],
					"resources": {
						"limits": {
							"cpu": "100m",
							"memory": "128Mi",
						},
						"requests": {
							"cpu": "50m",
							"memory": "64Mi",
						},
					},
					"volumeMounts": [{
						"name": "data-volume",
						"mountPath": "/data",
					}],
				}],
				"containers": [{
					"name": "app-container",
					"image": "nginx:latest",
					"ports": [{
						"containerPort": 80,
						"name": "http",
						"protocol": "TCP",
					}],
					"env": [
						{
							"name": "DATABASE_URL",
							"valueFrom": {"secretKeyRef": {
								"name": "db-credentials",
								"key": "url",
							}},
						},
						{
							"name": "API_KEY",
							"valueFrom": {"secretKeyRef": {
								"name": "app-secret",
								"key": "api-key",
							}},
						},
						{
							"name": "APP_VERSION",
							"value": "1.0",
						},
					],
					"resources": {
						"limits": {
							"cpu": "500m",
							"memory": "512Mi",
						},
						"requests": {
							"cpu": "100m",
							"memory": "256Mi",
						},
					},
					"livenessProbe": {
						"httpGet": {
							"path": "/healthz",
							"port": 80,
						},
						"initialDelaySeconds": 15,
						"periodSeconds": 10,
						"timeoutSeconds": 5,
						"successThreshold": 1,
						"failureThreshold": 3,
					},
					"readinessProbe": {
						"tcpSocket": {"port": 80},
						"initialDelaySeconds": 5,
						"periodSeconds": 5,
						"timeoutSeconds": 2,
						"successThreshold": 1,
						"failureThreshold": 3,
					},
					"startupProbe": {
						"httpGet": {
							"path": "/startup",
							"port": 80,
						},
						"initialDelaySeconds": 30,
						"periodSeconds": 5,
						"timeoutSeconds": 5,
						"failureThreshold": 6,
					},
					"volumeMounts": [
						{
							"name": "data-volume",
							"mountPath": "/app/data",
						},
						{
							"name": "config-volume",
							"mountPath": "/app/config",
							"readOnly": true,
						},
						{
							"name": "secret-volume",
							"mountPath": "/app/secrets",
							"readOnly": true,
						},
						{
							"name": "persistent-volume",
							"mountPath": "/app/persistent",
						},
					],
					"lifecycle": {
						"postStart": {"exec": {"command": [
							"/bin/sh",
							"-c",
							"echo 'Application started'",
						]}},
						"preStop": {"exec": {"command": [
							"/bin/sh",
							"-c",
							"sleep 5 && echo 'Application stopping'",
						]}},
					},
					"securityContext": {
						"privileged": false,
						"runAsUser": 1000,
						"runAsGroup": 2000,
						"runAsNonRoot": true,
						"seLinuxOptions": {
							"level": "s0:c1,c2",
							"role": "object_r",
							"type": "container_file_t",
						},
						"capabilities": {
							"add": ["NET_BIND_SERVICE"],
							"drop": ["ALL"],
						},
						"readOnlyRootFilesystem": true,
						"allowPrivilegeEscalation": false,
						"procMount": "Default",
					},
				}],
				"affinity": {
					"nodeAffinity": {"requiredDuringSchedulingIgnoredDuringExecution": {"nodeSelectorTerms": [{"matchExpressions": [{
						"key": "kubernetes.io/arch",
						"operator": "In",
						"values": ["amd64"],
					}]}]}},
					"podAffinity": {"preferredDuringSchedulingIgnoredDuringExecution": [{
						"weight": 100,
						"podAffinityTerm": {
							"labelSelector": {"matchLabels": {
								"app": "app",
								"tier": "backend",
							}},
							"topologyKey": "kubernetes.io/hostname",
						},
					}]},
					"podAntiAffinity": {"requiredDuringSchedulingIgnoredDuringExecution": [{
						"labelSelector": {"matchLabels": {"app": "app"}},
						"topologyKey": "topology.kubernetes.io/zone",
					}]},
				},
				"tolerations": [
					{
						"key": "node.kubernetes.io/unreachable",
						"operator": "Exists",
						"effect": "NoExecute",
						"tolerationSeconds": 300,
					},
					{
						"key": "node.kubernetes.io/not-ready",
						"operator": "Exists",
						"effect": "NoExecute",
						"tolerationSeconds": 300,
					},
					{
						"key": "special-node",
						"operator": "Equal",
						"value": "true",
						"effect": "NoSchedule",
					},
				],
				"dnsPolicy": "ClusterFirst",
				"dnsConfig": {
					"nameservers": ["10.0.0.10"],
					"searches": [
						"default.svc.cluster.local",
						"svc.cluster.local",
						"cluster.local",
					],
					"options": [{
						"name": "ndots",
						"value": "5",
					}],
				},
				"serviceAccountName": "app-sa",
				"automountServiceAccountToken": true,
				"shareProcessNamespace": false,
				"terminationGracePeriodSeconds": 30,
				"activeDeadlineSeconds": 600,
				"hostNetwork": false,
				"hostPID": false,
				"hostIPC": false,
				"securityContext": {
					"runAsUser": 1000,
					"runAsGroup": 2000,
					"fsGroup": 3000,
					"supplementalGroups": [
						4000,
						5000,
					],
				},
				"topologySpreadConstraints": [
					{
						"maxSkew": 1,
						"topologyKey": "kubernetes.io/zone",
						"whenUnsatisfiable": "DoNotSchedule",
						"labelSelector": {"matchLabels": {"app": "app"}},
					},
					{
						"maxSkew": 2,
						"topologyKey": "kubernetes.io/hostname",
						"whenUnsatisfiable": "ScheduleAnyway",
						"labelSelector": {"matchLabels": {"app": "app"}},
					},
				],
			},
		},
	},
}

missing_startup_probe := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {"name": "app-missing-startup"},
	"spec": {
		"selector": {"matchLabels": {"app": "app-missing-startup"}},
		"replicas": 1,
		"template": {
			"metadata": {"labels": {"app": "app-missing-startup"}},
			"spec": {"containers": [{
				"name": "container",
				"image": "nginx:latest",
				"livenessProbe": {
					"httpGet": {
						"path": "/healthz",
						"port": 80,
					},
					"initialDelaySeconds": 3,
					"periodSeconds": 3,
				},
				"readinessProbe": {
					"httpGet": {
						"path": "/readyz",
						"port": 80,
					},
					"initialDelaySeconds": 5,
					"periodSeconds": 5,
				},
			}]},
		},
	},
}

missing_probes := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {"name": "app-missing-probes"},
	"spec": {
		"selector": {"matchLabels": {"app": "app-missing-probes"}},
		"replicas": 1,
		"template": {
			"metadata": {"labels": {"app": "app-missing-probes"}},
			"spec": {"containers": [{
				"name": "container",
				"image": "nginx:latest",
			}]},
		},
	},
}

invalid_probe_ports := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {"name": "invalid-probe-ports"},
	"spec": {
		"selector": {"matchLabels": {"app": "invalid-probe-ports"}},
		"replicas": 1,
		"template": {
			"metadata": {"labels": {"app": "invalid-probe-ports"}},
			"spec": {"containers": [{
				"name": "container",
				"image": "nginx:latest",
				"ports": [
					{
						"containerPort": 8080,
						"name": "http",
						"protocol": "TCP",
					},
					{
						"containerPort": 443,
						"name": "HTTPS",
						"protocol": "TCP",
					},
				],
				"livenessProbe": {
					"httpGet": {
						"path": "/healthz",
						"port": 80,
					},
					"initialDelaySeconds": 3,
					"periodSeconds": 3,
				},
				"readinessProbe": {
					"httpGet": {
						"path": "/readyz",
						"port": 80,
					},
					"initialDelaySeconds": 5,
					"periodSeconds": 5,
				},
				"startupProbe": {
					"tcpSocket": {"port": 999},
					"initialDelaySeconds": 5,
					"periodSeconds": 5,
				},
			}]},
		},
	},
}

missing_template_labels := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "missing_template_labels",
		"labels": {"app_id": "missing_template_labels"},
	},
	"spec": {
		"selector": {"matchLabels": {"app_id": "missing_template_labels"}},
		"replicas": 1,
		"template": {"spec": {}},
	},
}

missing_selector_labels := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "missing_selector_labels",
		"labels": {"app_id": "missing_selector_labels"},
	},
	"spec": {
		"template": {"spec": {}},
		"replicas": 1,
	},
}

invalid_spec_labels := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "invalid_selector_labels",
		"labels": {"app_id": "invalid_selector_labels"},
	},
	"spec": {
		"selector": {"matchLabels": {"app_id": "invalid_selector_labels"}},
		"replicas": 1,
		"template": {
			"metadata": {"labels": {"app": "invalid_selector_labels"}},
			"spec": {},
		},
	},
}
