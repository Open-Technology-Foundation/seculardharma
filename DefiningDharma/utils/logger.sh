#!/bin/bash
#shellcheck disable=SC2034,SC1091
set -euo pipefail

# ==============================================================================
# logger.sh - Centralized logging library for DefiningDharma scripts
# Version: 1.0.0
# ==============================================================================
#
# This library provides standardized logging functions for all scripts.
# 
# Usage:
#   source /path/to/utils/logger.sh
#
# Environment Variables:
#   LOGFILE       - Override default log file location
#   LOG_LEVEL     - Set minimum log level (DEBUG|INFO|WARN|ERROR)
#   LOG_TO_STDERR - Also log to stderr (1|0, default: 1)
#   LOG_COLOR     - Enable colored output (1|0, default: auto-detect)
#   LOG_DATE_FMT  - Date format for timestamps (default: ISO-8601)
#
# Functions:
#   log_debug "message"  - Debug level logging
#   log_info "message"   - Info level logging  
#   log_warn "message"   - Warning level logging
#   log_error "message"  - Error level logging
#   log_setup            - Initialize logging (called automatically)
#
# ==============================================================================

readonly LOGGER_VERSION='1.0.0'

# Determine script context
if [[ -n "${PRG0:-}" ]]; then
  readonly LOGGER_SCRIPT="${PRG0}"
else
  readonly LOGGER_SCRIPT="${BASH_SOURCE[-1]:-${0}}"
fi
readonly LOGGER_SCRIPT_NAME="${LOGGER_SCRIPT##*/}"
readonly LOGGER_SCRIPT_DIR="${LOGGER_SCRIPT%/*}"

# Log levels
declare -Ag LOG_LEVELS=(
  [DEBUG]=0
  [INFO]=1
  [WARN]=2
  [ERROR]=3
)

# Default configuration
declare -g  LOG_LEVEL="${LOG_LEVEL:-INFO}"
declare -ig LOG_TO_STDERR="${LOG_TO_STDERR:-1}"
declare -g  LOG_DATE_FMT="${LOG_DATE_FMT:-%Y-%m-%d %H:%M:%S}"
declare -ig LOG_INITIALIZED=0

# Color codes (if supported)
declare -g LOG_COLOR_RESET=""
declare -g LOG_COLOR_DEBUG=""
declare -g LOG_COLOR_INFO=""
declare -g LOG_COLOR_WARN=""
declare -g LOG_COLOR_ERROR=""

# ==============================================================================
# Utility Functions
# ==============================================================================

# Check if colors are supported
_supports_color() {
  # Check if explicitly disabled
  [[ "${LOG_COLOR:-}" == "0" ]] && return 1
  
  # Check if in terminal and supports colors
  if [[ -t 2 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    if command -v tput &>/dev/null && tput colors &>/dev/null; then
      [[ $(tput colors) -ge 8 ]] && return 0
    fi
  fi
  
  return 1
}

# Initialize color codes
_init_colors() {
  if _supports_color; then
    LOG_COLOR_RESET=$'\e[0m'
    LOG_COLOR_DEBUG=$'\e[90m'     # Dark gray
    LOG_COLOR_INFO=$'\e[36m'      # Cyan
    LOG_COLOR_WARN=$'\e[33m'      # Yellow
    LOG_COLOR_ERROR=$'\e[31m'     # Red
  fi
}

# Get default log file path
_get_default_logfile() {
  local script_name="${LOGGER_SCRIPT_NAME%.sh}"
  local log_dir="${LOGGER_SCRIPT_DIR}/logs"
  
  # Create logs directory if it doesn't exist
  [[ ! -d "$log_dir" ]] && mkdir -p "$log_dir"
  
  echo "${log_dir}/${script_name}.log"
}

# ==============================================================================
# Core Logging Functions
# ==============================================================================

# Initialize logging system
log_setup() {
  # Prevent multiple initializations
  ((LOG_INITIALIZED)) && return 0
  
  # Set log file (use environment variable or default)
  if [[ -z "${LOGFILE:-}" ]]; then
    LOGFILE=$(_get_default_logfile)
  fi
  
  # Ensure log directory exists
  local log_dir="${LOGFILE%/*}"
  [[ ! -d "$log_dir" ]] && mkdir -p "$log_dir"
  
  # Initialize colors
  _init_colors
  
  # Validate log level
  if [[ -z "${LOG_LEVELS[$LOG_LEVEL]:-}" ]]; then
    LOG_LEVEL="INFO"
  fi
  
  # Mark as initialized
  LOG_INITIALIZED=1
  
  # Log initialization
  log_info "Logger initialized (v${LOGGER_VERSION}) for ${LOGGER_SCRIPT_NAME}"
  log_debug "Log file: ${LOGFILE}"
  log_debug "Log level: ${LOG_LEVEL}"
}

# Core logging function
_log() {
  local level="$1"
  shift
  local message="$*"
  
  # Initialize if not done yet
  ((LOG_INITIALIZED)) || log_setup
  
  # Check if we should log this level
  local level_num="${LOG_LEVELS[$level]}"
  local current_level_num="${LOG_LEVELS[$LOG_LEVEL]}"
  [[ $level_num -lt $current_level_num ]] && return 0
  
  # Format timestamp
  local timestamp
  timestamp=$(date +"$LOG_DATE_FMT")
  
  # Format log entry
  local log_entry="${timestamp} [${level}] ${LOGGER_SCRIPT_NAME}: ${message}"
  
  # Write to log file
  if [[ -n "${LOGFILE:-}" ]]; then
    echo "$log_entry" >> "$LOGFILE"
  fi
  
  # Write to stderr if enabled
  if ((LOG_TO_STDERR)); then
    local color_start=""
    local color_end=""
    
    case "$level" in
      DEBUG) color_start="$LOG_COLOR_DEBUG" ;;
      INFO)  color_start="$LOG_COLOR_INFO" ;;
      WARN)  color_start="$LOG_COLOR_WARN" ;;
      ERROR) color_start="$LOG_COLOR_ERROR" ;;
    esac
    
    [[ -n "$color_start" ]] && color_end="$LOG_COLOR_RESET"
    
    >&2 echo "${color_start}${log_entry}${color_end}"
  fi
}

# Public logging functions
log_debug() {
  _log "DEBUG" "$@"
}

log_info() {
  _log "INFO" "$@"
}

log_warn() {
  _log "WARN" "$@"
}

log_error() {
  _log "ERROR" "$@"
}

# ==============================================================================
# Compatibility Functions
# ==============================================================================

# For scripts that use vinfo/vwarn/error pattern
vinfo() {
  log_info "$@"
}

vwarn() {
  log_warn "$@"
}
warn() {
  log_warn "$@"
}

error() {
  log_error "$@"
}

# ==============================================================================
# Logrotate Setup Helper
# ==============================================================================

# Generate logrotate configuration
generate_logrotate_config() {
  local logfile="${1:-$LOGFILE}"
  
  cat <<EOF
# Logrotate configuration for DefiningDharma logs
${logfile} {
    daily
    rotate 7
    maxsize 100M
    compress
    delaycompress
    missingok
    notifempty
    create 0644 $(id -un) $(id -gn)
    sharedscripts
    postrotate
        # Optional: send signal to reload logs if needed
        # killall -USR1 your_daemon 2>/dev/null || true
    endscript
}
EOF
}

# ==============================================================================
# Symlink Management
# ==============================================================================

# Create symlink in /var/log if needed
create_log_symlink() {
  local target_dir="/var/log"
  local logfile="${1:-$LOGFILE}"
  local link_name="${logfile##*/}"
  
  # Check if running with sudo
  if [[ $EUID -ne 0 ]]; then
    log_debug "Not running as root, skipping symlink creation in $target_dir"
    return 0
  fi
  
  # Create symlink if it doesn't exist
  local symlink="${target_dir}/${link_name}"
  if [[ ! -L "$symlink" ]]; then
    ln -sf "$logfile" "$symlink"
    log_info "Created symlink: $symlink -> $logfile"
  else
    log_debug "Symlink already exists: $symlink"
  fi
}

# ==============================================================================
# Auto-initialization
# ==============================================================================

log_setup

#fin
