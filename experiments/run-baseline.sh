#!/bin/bash

PROFILE=workload/baseline.arrival
SCRIPT=workload/browsing.lua
OUT=results/raw/baseline.csv

echo "Running baseline..."

load-generator \
  --arrival-rate $PROFILE \
  --script $SCRIPT \
  --output $OUT