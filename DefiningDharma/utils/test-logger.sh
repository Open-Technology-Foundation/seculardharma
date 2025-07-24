#!/bin/bash
#shellcheck disable=SC2034,SC1091
set -euo pipefail

# Test script for logger functionality

readonly PRG0="$(readlink -en -- "$0")"
readonly PRGDIR="${PRG0%/*}"
readonly PRG="${PRG0##*/}"

# Source the logger library
source "$PRGDIR/logger.sh"

# Test different log levels
log_info "Testing logger functionality"
log_debug "This is a debug message (only visible if LOG_LEVEL=DEBUG)"
log_info "This is an info message"
log_warn "This is a warning message"
log_error "This is an error message"

# Test with environment variable
echo
echo "Testing with custom LOGFILE..."
export LOGFILE="/tmp/test-custom.log"
log_info "This should go to $LOGFILE"

# Test quiet mode
echo
echo "Testing quiet mode..."
export LOG_TO_STDERR=0
log_info "This should only go to the log file, not stderr"
export LOG_TO_STDERR=1

# Test color support
echo
echo "Testing color output..."
log_info "Info messages are in cyan"
log_warn "Warning messages are in yellow"
log_error "Error messages are in red"

# Show log file contents
echo
echo "Log file contents:"
echo "=================="
if [[ -f "$LOGFILE" ]]; then
  tail -10 "$LOGFILE"
else
  echo "No log file found at: $LOGFILE"
fi

echo
log_info "Logger test complete!"

#fin