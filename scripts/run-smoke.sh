#!/usr/bin/env bash
set -euo pipefail

echo "Running JMeter smoke test plan..."
mvn verify -Djmeter.test.files.included="smoke.jmx" \
           -Djmeter.save.saveservice.output_format=csv
echo "Smoke test complete. Results: target/jmeter/results/"
