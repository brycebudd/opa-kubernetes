package volumes.volume_fixture

valid_volumes := {
  "kind": "Deployment",
  "metadata": {
    "name": "valid-volumes"
  },
  "spec": {
    "volumes": [
      { "name": "volume1" },
      { "name": "volume2" }
    ],
    "containers": [
      {
        "name": "container1",
        "volumeMounts": [
          { "name": "volume1" }
        ]
      },
      {
        "name": "container2",
        "volumeMounts": [
          { "name": "volume2" }
        ]
      }
    ]
  }
}

invalid_volumes := {
  "kind": "Deployment",
  "metadata": {
    "name": "invalid-volumes"
  },
  "spec": {
    "volumes": [
      { "name": "volume1" }, 
      { "name": "volume2" }
    ],
    "containers": [
      {
        "name": "container1",
        "volumeMounts": [
          { "name": "volume1" }
        ]
      },
      {
        "name": "container2",
        "volumeMounts": [
          { "name": "volume1" }
        ]
      },
      {
        "name": "container3",
        "volumeMounts": [
          { "name": "volume3" }
        ]
      }
    ]
  }
}