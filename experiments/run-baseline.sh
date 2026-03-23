#!/bin/bash

PROFILE=../workload/baseline.arrival
SCRIPT=../workload/teastore_browse.lua
OUT=results/baseline.csv

echo "Running baseline..."

java -jar httploadgenerator.jar \
  --arrival-rate $PROFILE \
  --script $SCRIPT \
  --base-url http://localhost:8080 \
  --output $OUT