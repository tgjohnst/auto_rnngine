#!/bin/bash

# if we decide to use conda envirnoments for snakemake and dependencies, activation / make happens here

./_run_pipeline.py "$@" # initiate pipeline run

# if we decide to use conda environments for snakemake and dependencies, unset $@, unset any vars, and deactivate here