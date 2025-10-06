<!-- markdownlint-disable-next-line -->

# <img src="https://cdn.bfldr.com/B686QPH3/at/w5hnjzb32k5wcrcxnwcx4ckg/Dynatrace_signet_RGB_HTML.svg?auto=webp&format=pngg" alt="DT logo" width="30"> Dynatrace Data Access & Partitioning

[![dt-badge](https://img.shields.io/badge/powered_by-DT_enablement-8A2BE2?logo=dynatrace)](https://github.com/dynatrace-wwse/enablement-codespaces-template)
[![Downloads](https://img.shields.io/docker/pulls/shinojosa/dt-enablement?logo=docker)](https://hub.docker.com/r/shinojosa/dt-enablement)
![Integration tests](https://github.com/dynatrace-wwse/enablement-codespaces-template/actions/workflows/integration-tests.yaml/badge.svg)
[![Version](https://img.shields.io/github/v/release/dynatrace-wwse/enablement-codespaces-template?color=blueviolet)](https://github.com/dynatrace-wwse/enablement-codespaces-template/releases)
[![Commits](https://img.shields.io/github/commits-since/dynatrace-wwse/enablement-codespaces-template/latest?color=ff69b4&include_prereleases)](https://github.com/dynatrace-wwse/enablement-codespaces-template/graphs/commit-activity)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=green)](https://github.com/dynatrace-wwse/enablement-codespaces-template/blob/main/LICENSE)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-green)](https://dynatrace-wwse.github.io/enablement-codespaces-template/)

---

The goal of this lab is to show you the best practices for configuring data access & partitioning in Dynatrace.

To spin up the environment with GitHub codespaces, go to Codespaces and then select 'New with options' or directly by:
[![clicking here](https://github.com/codespaces/badge.svg)](https://codespaces.new/dynatrace-ace/data-access-and-partitioning-codespaces?quickstart=1&machine=basicLinux32gb)

Check the configuration requirements in the docs below.

## [🧳 Start your journey here!](https://dynatrace-ace.github.io/data-access-and-partitioning-codespaces/)


## Start

cd .devcontainer 
source ./makefile.sh && start

## Delete

When you are finished with your codespace, you can comfortably delete it by typing in the Terminal:
`deleteCodespace`

## Running in Local

### Mac

We need colima (or multipass) to run easytrade

```
Your Mac (arm64)
└─ Colima VM (x86_64 Linux)  <-- Docker daemon lives here (context: colima)
   ├─ dt-enablement (your dev container)
   └─ kind-control-plane (your K8s node)
```

1. Install colima

```
brew update
brew install lima colima lima-additional-guestagents
brew upgrade lima colima || true
colima delete -f || true
colima start --arch x86_64 --memory 16 --cpu 8
docker context use colima
docker info | grep -E 'Context|Architecture'   # should show context: colima, Architecture: x86_64 
```