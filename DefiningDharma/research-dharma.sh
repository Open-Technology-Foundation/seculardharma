#!/bin/bash
#shellcheck disable=SC2034,SC1091,SC2155
set -euo pipefail

# ==============================================================================
# research-dharma.sh - Enhanced dharma research script with modular design
# Version: 2.0.0
# ==============================================================================

declare -r VERSION='2.0.0'
declare -r PRG0="$(readlink -en -- "$0")"
declare -r PRGDIR="${PRG0%/*}" PRG="${PRG0##*/}"

# ==============================================================================
# Configuration Section
# ==============================================================================

# Default values
declare -- model='sonnet4'
declare -i max_tokens=16000
declare -- temperature='0.3'
declare -- knowledgebase='seculardharma'
declare -- research_depth='standard'  # quick, standard, comprehensive
declare -- output_format='article'    # article, notes, structured
declare -- output='research-dharma'

# Logging configuration
declare -i VERBOSE=1
declare -g PRG0="${PRG0}"  # Export for logger.sh

# Directory configuration
declare -- md_output_dir='mdfiles'
declare -- html_output_dir='htmlfiles'
declare -- temp_dir="/tmp/${PRG}-$$"

# Source the logger library
source "$PRGDIR/utils/logger.sh"

# ==============================================================================
# Utility Functions
# ==============================================================================

# Keep vecho for compatibility but use logger
vecho() { if ((VERBOSE)); then log_info "$@"; fi; }
die() { local -i exitcode=1; if (($#)); then exitcode=$1; shift; fi; if (($#)); then log_error "$@"; fi; exit "$exitcode"; }
noarg() { if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then die 2 "Missing argument for option '$1'"; fi; true; }

cleanup() {
  local -i exitcode=${1:-0}
  [[ -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -t 0 ]] && printf '\e[?25h'
  exit "$exitcode"
}

trap 'cleanup $?' EXIT SIGINT SIGTERM

# Progress indicator
progress() {
  if ((VERBOSE)); then
    # step="$1" total="$2" description="$3"
    >&2 echo "[$1/$2] $3"
  fi
}

# ==============================================================================
# Usage and Help
# ==============================================================================

usage() {
  cat <<EOT
$PRG $VERSION - Enhanced dharma research with modular design

Usage:
  $PRG [OPTIONS]

Options:
  -m, --model MODEL         Set LLM model (default: $model)
  -M, --max-tokens TOKENS   Set max tokens (default: $max_tokens)
  -t, --temperature TEMP    Set temperature (default: $temperature)
  -o, --output NAME         Set output filename (default: $output)
  -d, --depth LEVEL         Research depth: quick|standard|comprehensive
                           (default: $research_depth)
  -f, --format FORMAT       Output format: article|notes|structured
                           (default: $output_format)
  -k, --knowledgebase KB    Knowledge base name (default: $knowledgebase)
                           Use 'none' to skip knowledge base
  -v, --verbose             Increase output verbosity
  -q, --quiet               Suppress non-error messages
  -V, --version             Display version
  -h, --help                Display this help

Examples:
  # Quick research with GPT-4
  $PRG -m gpt-4o -d quick

  # Comprehensive research with higher temperature
  $PRG -m sonnet -d comprehensive -t 0.7

  # Generate structured notes
  $PRG -f notes -o dharma-research-notes

EOT
  exit "${1:-0}"
}

# ==============================================================================
# System Prompts
# ==============================================================================

get_system_prompt() {
  local format="$1"
  local prompt
  
  case "$format" in
    article)
      prompt="You are a philosophical researcher and secular dharma scholar with expertise in:
- Comparative philosophy and religious studies
- Evolutionary psychology and neuroscience
- Anthropology and sociology
- Systems thinking and complexity theory

Your task is to explore dharma as both a historical concept and living framework for ethical life. Write with academic rigor but accessible prose. Ground abstract concepts in concrete examples. Be culturally sensitive while maintaining analytical clarity.

Guidelines:
- Integrate historical, scientific, and contemporary perspectives
- Use cross-cultural examples to illustrate universal patterns
- Address both individual and collective dimensions
- Consider evolutionary and neuroscientific insights
- Maintain critical perspective while respecting traditions"
      ;;
    
    notes)
      prompt="You are a research assistant compiling comprehensive notes on dharma. Organize information clearly with:
- Key concepts and definitions
- Historical developments
- Cross-cultural comparisons
- Contemporary applications
- Critical perspectives
- Further research directions

Use bullet points, clear headings, and concise explanations. Include relevant quotes and references where appropriate."
      ;;
    
    structured)
      prompt="You are a data analyst examining dharma systematically. Structure your responses as:
- Concept definitions
- Historical timeline
- Cultural variations
- Common patterns
- Functional analysis
- Modern applications
- Empirical support

Use clear categorization and consistent formatting. Focus on extractable insights and patterns."
      ;;
    
    *)
      prompt="You are a dharma researcher providing thoughtful, comprehensive analysis."
      ;;
  esac
  
  echo "$prompt"
}

# ==============================================================================
# Research Questions Framework
# ==============================================================================

# Declare associative array for themes
declare -A research_themes
research_themes[foundations]="Foundational Concepts"
research_themes[emergence]="Historical Emergence"
research_themes[philosophy]="Philosophical Dimensions"
research_themes[culture]="Cross-Cultural Analysis"
research_themes[psychology]="Psychological & Neuroscientific"
research_themes[contemporary]="Contemporary Applications"
research_themes[critical]="Critical Perspectives"
research_themes[future]="Future Directions"

get_research_questions() {
  local depth="$1"
  local -a questions=()
  
  # Foundational concepts
  questions+=(
    "foundations|Core Etymology|Trace the etymology of 'dharma' beyond Sanskrit to Proto-Indo-European roots. What cognitive and social functions do these linguistic origins reveal about humanity's need for ethical frameworks?"
  )
  
  questions+=(
    "foundations|Universal Pattern|How does dharma represent a universal cognitive pattern that emerges independently across cultures? What evolutionary pressures drive humans to create dharmic frameworks?"
  )
  
  # Historical emergence
  questions+=(
    "emergence|Axial Age Catalyst|What specific socio-economic and psychological pressures during the Axial Age (800-200 BCE) catalyzed the simultaneous emergence of dharmic thinking across disconnected civilizations?"
  )
  
  questions+=(
    "emergence|Urban Complexity|How did the transition from kinship-based tribes to anonymous urban societies necessitate explicit dharmic codes? What problems did these frameworks solve?"
  )
  
  # Philosophical dimensions
  questions+=(
    "philosophy|Tension Resolution|How do dharmic systems navigate the fundamental tension between individual autonomy and collective welfare? Provide specific examples of how different traditions resolve this."
  )
  
  questions+=(
    "philosophy|Metacognitive Function|What role does dharma play in human metacognition - our ability to think about thinking? How do dharmic practices shape cognitive development?"
  )
  
  # Cross-cultural analysis
  questions+=(
    "culture|African Ubuntu|Analyze Ubuntu ('I am because we are') as a dharmic framework. How does it differ from individualistic dharmas while serving similar social functions?"
  )
  
  questions+=(
    "culture|Indigenous Wisdom|Examine indigenous dharmic systems (e.g., Native American, Aboriginal Australian) that predate written traditions. What can oral dharmas teach us about essential vs. cultural elements?"
  )
  
  if [[ $depth == "standard" ]] || [[ $depth == "comprehensive" ]]; then
    # Psychological & neuroscientific
    questions+=(
      "psychology|Neurological Basis|What neuroscientific evidence supports dharmic intuitions about interconnectedness, compassion, and ethical behavior? How do contemplative practices alter brain structure?"
    )
    
    questions+=(
      "psychology|Evolutionary Psychology|From an evolutionary psychology perspective, how do dharmic frameworks exploit cognitive biases and social instincts to promote cooperation? What are the adaptive advantages?"
    )
    
    # Contemporary applications
    questions+=(
      "contemporary|Secular Translation|How can traditional dharmic insights be translated into secular frameworks without losing their transformative power? What are successful examples?"
    )
    
    questions+=(
      "contemporary|Digital Age Dharma|What new dharmic frameworks are emerging to address digital age challenges like information overload, social media, and AI? How do they differ from traditional forms?"
    )
  fi
  
  if [[ $depth == "comprehensive" ]]; then
    # Critical perspectives
    questions+=(
      "critical|Failure Modes|What are the common failure modes of dharmic systems? How do they become corrupted, co-opted by power structures, or turn exclusionary?"
    )
    
    questions+=(
      "critical|Cultural Appropriation|How can Western adoption of Eastern dharmic concepts avoid superficial appropriation while enabling genuine cross-cultural learning?"
    )
    
    questions+=(
      "critical|Dharma and Power|Examine how dharmic frameworks can both challenge and reinforce existing power structures. When do they liberate vs. oppress?"
    )
    
    # Future directions
    questions+=(
      "future|Planetary Dharma|As humanity faces global challenges (climate change, inequality, technological disruption), what elements of a 'planetary dharma' are emerging?"
    )
    
    questions+=(
      "future|AI and Dharma|How might artificial intelligence require new dharmic frameworks? What ethical principles should guide human-AI coexistence?"
    )
    
    questions+=(
      "future|Post-Traditional|What would a post-traditional dharma look like that honors wisdom traditions while embracing scientific understanding and cultural pluralism?"
    )
  fi
  
  printf '%s\n' "${questions[@]}"
}

# ==============================================================================
# Context Management
# ==============================================================================

init_context() {
  mkdir -p "$temp_dir"
  : > "$temp_dir/full_context.txt"
  : > "$temp_dir/current_theme.txt"
}

add_to_context() {
  local theme="$1"
  local title="$2"
  local question="$3"
  local response="$4"
  
  {
    echo "=== Theme: ${research_themes[$theme]} ==="
    echo "--- $title ---"
    echo "Q: $question"
    echo "A: $response"
    echo
  } >> "$temp_dir/full_context.txt"
  
  # Keep theme-specific context
  {
    echo "--- $title ---"
    echo "$response"
    echo
  } >> "$temp_dir/theme_${theme}.txt"
}

get_context_for_question() {
  local current_theme="$1"
  local context=""
  
  # Include previous responses from same theme
  if [[ -f "$temp_dir/theme_${current_theme}.txt" ]]; then
    context=$(cat "$temp_dir/theme_${current_theme}.txt")
  fi
  
  # For comprehensive depth, include cross-theme insights
  if [[ $research_depth == "comprehensive" ]]; then
    # Add summary from other themes if they exist
    for theme in "${!research_themes[@]}"; do
      if [[ $theme != "$current_theme" ]] && [[ -f "$temp_dir/theme_${theme}.txt" ]]; then
        context+=$'\n\n'"[Context from ${research_themes[$theme]}]"
        # Include just first 500 chars as summary
        context+=$'\n'"$(head -c 500 "$temp_dir/theme_${theme}.txt")"
      fi
    done
  fi
  
  echo "$context"
}

# ==============================================================================
# LLM Interaction
# ==============================================================================

query_llm() {
  local system_prompt="$1"
  local question="$2"
  local context="$3"
  local reference_file="$temp_dir/context_ref.txt"
  
  vinfo "Querying LLM with question: ${question:0:50}..."
  
  # Prepare context file
  echo "$context" > "$reference_file"
  
  # Build the full prompt
  local prompt="Please provide a thoughtful, comprehensive response to the following question:

$question

Focus on depth of insight rather than length. Draw from multiple perspectives while maintaining clarity."
  
  # Call dv2 with appropriate parameters
  local response
  local dv2_args=(
    -s "$system_prompt"
    -t "$temperature"
    -m "$model"
    -M "$max_tokens"
    --log-file "$LOGFILE"
  )
  
  # Add knowledge base if specified and not 'none'
  if [[ -n "$knowledgebase" ]] && [[ "$knowledgebase" != "none" ]]; then
    dv2_args+=(-k "$knowledgebase")
  fi
  
  # Add reference file if it has content
  if [[ -s "$reference_file" ]]; then
    dv2_args+=(-r "$reference_file")
  fi
  
  if ! response=$(dv2 "${dv2_args[@]}" -- "$prompt" 2>&1); then
    error "Failed to query LLM: $response"
    return 1
  fi
  
  echo "$response"
}

# ==============================================================================
# Output Formatting
# ==============================================================================

format_output() {
  local format="$1"
  local content_file="$2"
  local output_file="$3"
  
  case "$format" in
    article)
      {
        echo "# Dharma: A Comprehensive Research Exploration"
        echo
        echo "*Generated on $(date '+%Y-%m-%d') using model: $model*"
        echo
        
        # Process content by theme
        for theme in foundations emergence philosophy culture psychology contemporary critical future; do
          if grep -q "Theme: ${research_themes[$theme]}" "$content_file" 2>/dev/null; then
            echo "## ${research_themes[$theme]}"
            echo
            
            # Extract content for this theme
            awk "/Theme: ${research_themes[$theme]}/,/^=== Theme:/" "$content_file" |
              grep -v "^===" |
              sed 's/^--- \(.*\) ---$/### \1/' |
              sed 's/^Q: /> /' |
              sed 's/^A: //'
          fi
        done
      } > "$output_file"
      ;;
    
    notes)
      {
        echo "# Dharma Research Notes"
        echo
        echo "**Model:** $model | **Depth:** $research_depth | **Date:** $(date '+%Y-%m-%d')"
        echo
        
        # Simple reformatting with clear sections
        sed 's/^=== Theme: \(.*\) ===$/## \1/' "$content_file" |
          sed 's/^--- \(.*\) ---$/### \1/' |
          sed 's/^Q: /** Question:** /' |
          sed 's/^A: /** Response:**\n/'
      } > "$output_file"
      ;;
    
    structured)
      {
        echo "# Dharma Research - Structured Data"
        echo
        echo '```yaml'
        echo "metadata:"
        echo "  model: $model"
        echo "  depth: $research_depth"
        echo "  date: $(date -I)"
        echo "  version: $VERSION"
        echo
        echo "themes:"
        
        # Convert to structured format
        local current_theme=""
        while IFS= read -r line; do
          if [[ $line =~ ^===\ Theme:\ (.*)\ ===$ ]]; then
            current_theme="${BASH_REMATCH[1]}"
            echo "  - name: \"$current_theme\""
            echo "    questions:"
          elif [[ $line =~ ^---\ (.*)\ ---$ ]]; then
            echo "      - title: \"${BASH_REMATCH[1]}\""
          elif [[ $line =~ ^Q:\ (.*)$ ]]; then
            echo "        question: \"${BASH_REMATCH[1]}\""
          elif [[ $line =~ ^A:\ (.*)$ ]]; then
            echo "        response: |"
            echo "          ${BASH_REMATCH[1]}"
          fi
        done < "$content_file"
        
        echo '```'
      } > "$output_file"
      ;;
  esac
}

# ==============================================================================
# Main Research Loop
# ==============================================================================

main() {
  # Parse command line arguments
  while (($#)); do
    case "$1" in
      -m|--model)         noarg "$@"; shift; model="$1" ;;
      -M|--max-tokens)    noarg "$@"; shift; max_tokens="$1" ;;
      -t|--temperature)   noarg "$@"; shift; temperature="$1" ;;
      -o|--output)        noarg "$@"; shift; output="$1" ;;
      -d|--depth)         noarg "$@"; shift; research_depth="$1" ;;
      -f|--format)        noarg "$@"; shift; output_format="$1" ;;
      -k|--knowledgebase) noarg "$@"; shift; knowledgebase="$1" ;;
      -v|--verbose)       VERBOSE=1; export LOG_TO_STDERR=1 ;;
      -q|--quiet)         VERBOSE=0; export LOG_TO_STDERR=0 ;;
      -V|--version)       echo "$PRG $VERSION"; exit 0 ;;
      -h|--help)          usage 0 ;;
      -*)                 die 22 "Invalid option '$1'" ;;
      *)                  die 2 "Invalid argument '$1'" ;;
    esac
    shift
  done
  
  # Validate arguments
  case "$research_depth" in
    quick|standard|comprehensive) ;;
    *) die 2 "Invalid depth: $research_depth (use: quick|standard|comprehensive)" ;;
  esac
  
  case "$output_format" in
    article|notes|structured) ;;
    *) die 2 "Invalid format: $output_format (use: article|notes|structured)" ;;
  esac
  
  # Initialize
  vinfo "Starting dharma research (model: $model, depth: $research_depth)"
  vinfo "Output format: $output_format, Knowledge base: $knowledgebase"
  init_context
  
  # Prepare output
  mkdir -p "$md_output_dir" "$html_output_dir"
  output_md="$md_output_dir/${output}_${model}.md"
  output_html="$html_output_dir/${output}-${model}.html"
  
  # Get questions based on depth
  local -a questions=()
  while IFS= read -r line; do
    questions+=("$line")
  done < <(get_research_questions "$research_depth")
  local total_questions=${#questions[@]}
  
  vinfo "Processing $total_questions questions across ${#research_themes[@]} themes"
  vinfo "First question: ${questions[0]:0:50}..." || vinfo "No questions found!"
  
  # Get system prompt
  local system_prompt
  system_prompt=$(get_system_prompt "$output_format")
  
  # Process each question
  local i=0
  for question_data in "${questions[@]}"; do
    i=$((i + 1))
    vinfo "Processing question $i/$total_questions"
    
    # Parse question data
    IFS='|' read -r theme title question <<< "$question_data"
    vinfo "Theme: $theme, Title: $title"
    
    progress "$i" "$total_questions" "${research_themes[$theme]}: $title"
    
    # Get relevant context
    local context
    context=$(get_context_for_question "$theme")
    
    # Query LLM
    local response
    if ! response=$(query_llm "$system_prompt" "$question" "$context"); then
      error "Failed to process question: $title"
      continue
    fi
    
    # Add to context
    add_to_context "$theme" "$title" "$question" "$response"
    
    # Brief pause to avoid rate limiting
    sleep 0.5
  done
  
  vinfo "Formatting output as $output_format"
  
  # Check if context file exists
  if [[ ! -f "$temp_dir/full_context.txt" ]]; then
    error "No context file found at $temp_dir/full_context.txt"
    exit 1
  fi
  
  # Format and save output
  format_output "$output_format" "$temp_dir/full_context.txt" "$output_md"
  
  # Convert to HTML if it's an article
  if [[ $output_format == "article" ]] && command -v pandoc &>/dev/null; then
    vinfo "Converting to HTML"
    pandoc --from=markdown --to=html \
      --standalone \
      --metadata title="Dharma Research" \
      "$output_md" \
      -o "$output_html" 2>/dev/null || vwarn "HTML conversion failed"
  fi
  
  if [[ -f "$output_md" ]]; then
    vinfo "Research complete. Output saved to:"
    vinfo "  Markdown: $output_md"
    [[ -f "$output_html" ]] && vinfo "  HTML: $output_html"
  else
    error "Failed to create output file: $output_md"
    exit 1
  fi
}

# Run main function
main "$@"

#fin
