#!/bin/bash
#loading functions to script
export SECONDS=0
source .devcontainer/util/source_framework.sh

deployDynatraceConfig

printInfoSection "Your dev container finished creating"
