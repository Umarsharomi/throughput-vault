#!/usr/bin/env bash
set -euo pipefail

forge fmt --check
forge build
forge test --gas-report
forge snapshot --check
