
![Logo](./assets/logo.png)

## About

Container image with a bunch of useful Helm tools I made for myself.

## Includes

- helm
- helm-docs
- helmfile
- kubectl
- make
- Several helm plugins
- kubeconform, kube-score, kube-linter

## Run Locally

Clone the project

```bash
  git clone https://github.com/KJone1/helm-tools.git
```

Go to the project directory

```bash
  cd helm-tools
```

Build the Container

```bash
  sudo docker build -f helm-tools.Dockerfile -t helmtools:v1 .
```

Run

```bash
  sudo docker run -v {dir with helm chart}:/opt/charts -it helmtools:v1 ash
```

## Authors

- [@KJone1](https://github.com/KJone1)
