# jmeter-performance

> **GitHub repo description:** JMeter performance test suite — smoke, load, and stress test plans targeting reqres.in REST API via Maven plugin, with HTML/JTL reporting.

A production-grade Apache JMeter performance testing project demonstrating enterprise load testing patterns: parameterised thread groups, JSON path extraction and assertions, duration-based assertions, reusable Maven properties, and automated HTML report generation via the JMeter Maven Plugin.

## Tech Stack

| Component      | Technology                         |
|----------------|------------------------------------|
| Load Tool      | Apache JMeter 5.6.3                |
| Build / Runner | Maven 3.9 + jmeter-maven-plugin    |
| Target         | reqres.in (public REST API)        |
| Reporting      | JMeter HTML Dashboard + JTL/CSV    |
| CI             | GitHub Actions                     |

## Project Structure

```
jmeter-performance/
├── .github/
│   └── workflows/
│       └── ci.yml
├── scripts/
│   ├── run-smoke.sh
│   ├── run-load.sh
│   └── run-stress.sh
├── src/
│   └── test/
│       └── jmeter/
│           ├── smoke.jmx       # 1 VU, 1 loop — sanity check
│           ├── load.jmx        # 20 VUs, 5 min sustained
│           └── stress.jmx      # 100 VUs, 10 min sustained
├── pom.xml
└── README.md
```

## Prerequisites

- [Java 17+](https://adoptium.net/)
- [Maven 3.9+](https://maven.apache.org/download.cgi)

> JMeter itself is downloaded automatically by the Maven plugin — no separate JMeter installation required.

## Running Tests

### Via Maven (recommended)

```bash
# Smoke — 1 VU, 1 iteration
mvn verify -Djmeter.test.files.included="smoke.jmx"

# Load — 20 VUs, 5 min (default params)
mvn verify -Djmeter.test.files.included="load.jmx"

# Stress — 100 VUs, 10 min (default params)
mvn verify -Djmeter.test.files.included="stress.jmx"

# Override thread count and duration at runtime
mvn verify -Djmeter.test.files.included="load.jmx" \
           -Dthreads=50 \
           -Dramp_up=60 \
           -Dduration=600
```

### Via scripts

```bash
chmod +x scripts/*.sh

bash scripts/run-smoke.sh
bash scripts/run-load.sh
bash scripts/run-stress.sh

# Override params
THREADS=50 RAMP_UP=60 DURATION=600 bash scripts/run-load.sh
```

## Test Plans

| Plan | VUs | Ramp-up | Duration | Assertions |
|------|-----|---------|----------|------------|
| `smoke.jmx` | 1 | 1s | 1 loop | HTTP 200/201, JSON path, response body |
| `load.jmx` | 20 | 30s | 5 min | HTTP codes, duration < 2s per request |
| `stress.jmx` | 100 | 60s | 10 min | HTTP codes, duration < 5s per request |

## API Endpoints Under Test

All plans exercise the following `reqres.in` endpoints:

| Request | Endpoint | Expected |
|---------|----------|----------|
| GET List Users | `GET /api/users?page=1` | 200, `$.data` array |
| GET Single User | `GET /api/users/{id}` | 200 |
| Create User | `POST /api/users` | 201, `$.id` present |
| Login | `POST /api/login` | 200, `$.token` present (smoke only) |

## Reports

After a test run, reports are available at:

```
target/jmeter/
├── reports/
│   └── smoke/          # HTML dashboard (open index.html)
└── results/
    ├── smoke-results.jtl
    ├── load-results.jtl
    └── stress-results.jtl
```

Open `target/jmeter/reports/<suite>/index.html` in a browser for the full HTML dashboard including response time graphs, throughput charts, and percentile tables.

## Parameterisation

All thread group parameters are controlled via Maven `-D` properties and fall back to sensible defaults defined in the JMX user-defined variables:

| Property | Default (load) | Default (stress) | Description |
|----------|---------------|-----------------|-------------|
| `base_url` | `reqres.in` | `reqres.in` | Target host |
| `threads` | `20` | `100` | Virtual users |
| `ramp_up` | `30` | `60` | Ramp-up seconds |
| `duration` | `300` | `600` | Sustained duration (seconds) |

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`):

1. **smoke-tests** — runs smoke plan on every push; fails CI on any assertion error
2. **load-tests** — runs after smoke passes; uses reduced thread count (10 VUs, 60s) to keep CI fast
3. Both jobs upload JMeter HTML reports and JTL files as artifacts
