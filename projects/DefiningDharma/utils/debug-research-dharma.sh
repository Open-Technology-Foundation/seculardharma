#!/bin/bash
set -euxo pipefail

# Run with extreme debugging
export PS4='+ ${BASH_SOURCE}:${LINENO}: '
bash -x ./research-dharma.sh -m gpt-4o -d quick -f notes -o test -k none 2>&1 \
    | grep -A5 -B5 "dv2\|query_llm" | head -100

#fin