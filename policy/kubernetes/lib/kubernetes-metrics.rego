package lib.kubernetes.metrics

# Utility function to retrieve all metrics from input.spec.metrics
get_all_metrics[metric] {
  input.spec.metrics[_].resource != null
  metric := input.spec.metrics[_].resource
}

get_all_metrics[metric] {
  input.spec.metrics[_].pods != null
  metric := input.spec.metrics[_].pods
}

get_all_metrics[metric] {
  input.spec.metrics[_].object != null
  metric := input.spec.metrics[_].object
}

# Function to retrieve only CPU utilization metrics
get_cpu_utilization_metrics[metric] {
  input.spec.metrics[_].resource.name == "cpu"
  input.spec.metrics[_].resource.target.type == "Utilization"
  metric := input.spec.metrics[_].resource
}

get_cpu_utilization_metrics[metric] {
  # may need to adjust this for custom cpu metric names
  input.spec.metrics[_].pods.metric.name == "cpu_usage_seconds_total" # Common CPU metric
  input.spec.metrics[_].pods.target.type == "Utilization"
  metric := input.spec.metrics[_].pods
}

get_cpu_utilization_metrics[metric] {
  # may need to adjust this for custom cpu metric names
  input.spec.metrics[_].object.metric.name == "cpu_usage_seconds_total" # Common CPU metric
  input.spec.metrics[_].object.target.type == "Utilization"
  metric := input.spec.metrics[_].object
}

# Function to retrieve only memory utilization metrics
get_memory_utilization_metrics[metric] {
  input.spec.metrics[_].resource.name == "memory"
  input.spec.metrics[_].resource.target.type == "Utilization"
  metric := input.spec.metrics[_].resource
}

get_memory_utilization_metrics[metric] {
  # may need to adjust this for custom memory metric names    
  input.spec.metrics[_].pods.metric.name == "memory_working_set_bytes" # Common memory metric
  input.spec.metrics[_].pods.target.type == "Utilization"
  metric := input.spec.metrics[_].pods
}

get_memory_utilization_metrics[metric] {
  # may need to adjust this for custom memory metric names        
  input.spec.metrics[_].object.metric.name == "memory_working_set_bytes" # Common memory metric
  input.spec.metrics[_].object.target.type == "Utilization"
  metric := input.spec.metrics[_].object
}