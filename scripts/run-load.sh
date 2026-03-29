#!/usr/bin/env bash
set -euo pipefail

THREADS="${THREADS:-20}"
RAMP_UP="${RAMP_UP:-30}"
DURATION="${DURATION:-300}"

echo "Running JMeter load test plan (threads=${THREADS}, ramp_up=${RAMP_UP}s, duration=${DURATION}s)..."
mvn verify -Djmeter.test.files.included="load.jmx" \
           -Djmeter.save.saveservice.output_format=csv \
           -Dthreads="${THREADS}" \
           -Dramp_up="${RAMP_UP}" \
           -Dduration="${DURATION}"
echo "Load test complete. Results: target/jmeter/results/"
