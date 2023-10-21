
![Logo](./assets/logo.png)

## About

Container image with a bunch of useful Helm tools I made for myself.

## Includes

- helm
- helm-docs
- helmfile
- kubectl
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

## Authors

- [@KJone1](https://github.com/KJone1)
