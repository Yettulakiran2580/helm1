# python-project Helm Chart

This chart deploys the `bharathchatakondu/python-web-app:latest` container on port 5000.

## Features

- Deployment with configurable replicas
- ClusterIP service exposing port 5000
- Customizable image tag, resources, node selectors, affinities, and tolerations

## Usage

```sh
helm install my-python-project ./python-project-chart
```

Customize via `values.yaml` or `--set` flags.
