#!/usr/bin/env bash
set -euo pipefail

THREADS="${THREADS:-100}"
RAMP_UP="${RAMP_UP:-60}"
DURATION="${DURATION:-600}"

echo "Running JMeter stress test plan (threads=${THREADS}, ramp_up=${RAMP_UP}s, duration=${DURATION}s)..."
mvn verify -Djmeter.test.files.included="stress.jmx" \
           -Djmeter.save.saveservice.output_format=csv \
           -Dthreads="${THREADS}" \
           -Dramp_up="${RAMP_UP}" \
           -Dduration="${DURATION}"
echo "Stress test complete. Results: target/jmeter/results/"
