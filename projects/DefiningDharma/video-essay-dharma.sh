#!/bin/bash
#shellcheck disable=SC2034,SC1091,SC2155
set -euo pipefail

# ==============================================================================
# video-essay-dharma.sh - Enhanced video essay generation with modular design
# Version: 2.0.0
# ==============================================================================

readonly VERSION='2.0.0'
readonly PRG0="$(readlink -en -- "$0")"
readonly PRGDIR="${PRG0%/*}"
readonly PRG="${PRG0##*/}"

# ==============================================================================
# Configuration Section
# ==============================================================================

# Default values
declare -- model='gpt-4o'
declare -i max_tokens=8000
declare -- temperature='0.7'
declare -- video_style='documentary'  # documentary, educational, narrative
declare -- video_length='10min'       # 5min, 10min, 15min, 30min
declare -- narrator_name=''           # Optional narrator name
declare -- output='dharma-video-essay'
declare -- research_file=''           # Research input file

# Directory configuration  
declare -- output_dir='video-scripts'
declare -- reference_dir='mdfiles'
declare -- temp_dir="/tmp/${PRG}-$$"

# Logging configuration
declare -i VERBOSE=1
declare -g PRG0="${PRG0}"  # Export for logger.sh

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
  exit "$exitcode"
}

trap 'cleanup $?' EXIT SIGINT SIGTERM

# Progress indicator
progress() {
  local step="$1"
  local total="$2"
  local description="$3"
  if ((VERBOSE)); then
    echo "[${step}/${total}] $description" >&2
  fi
}

# ==============================================================================
# Usage and Help
# ==============================================================================

usage() {
  cat <<EOT
$PRG $VERSION - Enhanced dharma video essay generation

Usage:
  $PRG [OPTIONS]

Options:
  -m, --model MODEL         Set LLM model (default: $model)
  -M, --max-tokens TOKENS   Set max tokens per section (default: $max_tokens)
  -t, --temperature TEMP    Set temperature (default: $temperature)
  -s, --style STYLE         Video style: documentary|educational|narrative
                           (default: $video_style)
  -l, --length LENGTH       Video length: 5min|10min|15min|30min
                           (default: $video_length)
  -n, --narrator NAME       Narrator name (optional)
  -r, --research FILE       Research input file (e.g., from research-dharma.sh)
  -o, --output NAME         Set output filename (default: $output)
  -v, --verbose             Increase output verbosity
  -q, --quiet               Suppress non-error messages
  -V, --version             Display version
  -h, --help                Display this help

Examples:
  # Generate 10-minute documentary using research
  $PRG -s documentary -l 10min -r mdfiles/dharma-research-notes_gpt-4o.md

  # Create educational video with custom narrator
  $PRG -s educational -n "Dr. Smith" -m sonnet

  # Generate narrative-style video essay
  $PRG -s narrative -l 15min -t 0.8

EOT
  exit "${1:-0}"
}

# ==============================================================================
# Video Structure Definitions
# ==============================================================================

get_video_sections() {
  local style="$1"
  local length="$2"
  local -a sections=()
  
  case "$style" in
    documentary)
      case "$length" in
        5min)
          sections=(
            "introduction|Opening: The Universal Question|Hook the viewer with the fundamental question of how to live ethically"
            "core_concepts|What is Dharma?|Explain the core concept and its universality across cultures"
            "contemporary|Dharma in Modern Life|Show how dharmic principles apply today"
            "conclusion|The Path Forward|Inspire viewers to explore their own dharmic path"
          )
          ;;
        10min)
          sections=(
            "introduction|Opening: The Universal Question|Hook with the question of ethical living across cultures"
            "etymology|The Roots of Dharma|Explore linguistic and conceptual origins"
            "universality|A Universal Pattern|Show how dharma emerges independently across cultures"
            "historical|The Axial Age Revolution|Examine the historical emergence of dharmic thinking"
            "diversity|Many Paths, One Purpose|Explore different dharmic traditions"
            "contemporary|Dharma in the Digital Age|Modern applications and challenges"
            "conclusion|Your Dharmic Journey|Inspire personal exploration"
          )
          ;;
        15min)
          sections=(
            "introduction|The Great Question|Open with humanity's eternal question of how to live"
            "etymology|Origins and Evolution|Deep dive into linguistic and conceptual roots"
            "cognitive|The Architecture of Ethics|Explore cognitive and evolutionary basis"
            "historical|The Axial Age Transformation|Detailed look at historical emergence"
            "traditions|Dharmic Diversity|Survey major dharmic traditions globally"
            "case_study_1|Ubuntu: We Are Because We Are|Deep dive into African dharma"
            "case_study_2|The Way of Tea: Japanese Dharma|Explore aesthetic dharmas"
            "science|Neuroscience Meets Ancient Wisdom|Modern scientific validation"
            "challenges|When Dharmas Fail|Critical examination of limitations"
            "future|Emerging Dharmas|New forms for new challenges"
            "conclusion|The Eternal Return|Reflect on timeless relevance"
          )
          ;;
        30min)
          # Add comprehensive 30-minute structure if needed
          sections=(
            "introduction|The Universal Question|Comprehensive opening"
            # ... more sections for 30-minute format
          )
          ;;
      esac
      ;;
      
    educational)
      case "$length" in
        5min)
          sections=(
            "introduction|Learning Objectives|What viewers will understand about dharma"
            "definition|Defining Dharma|Clear, accessible explanation"
            "examples|Dharma in Practice|Concrete examples from various cultures"
            "summary|Key Takeaways|Reinforce main concepts"
          )
          ;;
        # Add more educational formats
      esac
      ;;
      
    narrative)
      case "$length" in
        10min)
          sections=(
            "opening|A Personal Journey Begins|Start with relatable narrative"
            "discovery|Encountering Dharma|First exposure to the concept"
            "exploration|Seeking Understanding|Journey through different traditions"
            "challenge|Testing the Path|Personal challenges and insights"
            "transformation|Finding Your Dharma|Personal transformation"
            "reflection|The Journey Continues|Open-ended conclusion"
          )
          ;;
        # Add more narrative formats
      esac
      ;;
  esac
  
  printf '%s\n' "${sections[@]}"
}

# ==============================================================================
# System Prompts
# ==============================================================================

get_system_prompt() {
  local style="$1"
  local narrator="$2"
  local prompt=""
  
  case "$style" in
    documentary)
      prompt="You are an experienced documentary filmmaker and dharma scholar creating a video essay that explores dharma as a universal human phenomenon.

Your approach:
- Balance academic rigor with accessibility
- Use concrete examples and visual metaphors
- Build narrative tension and resolution
- Include diverse cultural perspectives
- Ground abstract concepts in human experience

Writing guidelines:
- Write for the spoken word (natural speech patterns)
- Include cues for visuals, B-roll, and graphics
- Vary pace and tone for engagement
- Use stories and examples to illustrate concepts
- Build each section to flow naturally into the next"
      ;;
      
    educational)
      prompt="You are an educator creating clear, engaging content about dharma for a general audience.

Your approach:
- Start with learning objectives
- Build concepts progressively
- Use clear definitions and examples
- Include visual aids and graphics
- Summarize key points

Writing guidelines:
- Use simple, clear language
- Define terms when first introduced
- Include plenty of examples
- Suggest educational graphics
- End sections with key takeaways"
      ;;
      
    narrative)
      prompt="You are a storyteller weaving a personal narrative about discovering and understanding dharma.

Your approach:
- Use personal, relatable language
- Build emotional connection
- Show transformation through story
- Include moments of insight
- Balance personal and universal

Writing guidelines:
- Write in first or second person
- Use sensory details
- Include emotional moments
- Show rather than tell
- Create narrative arc"
      ;;
  esac
  
  if [[ -n "$narrator" ]]; then
    prompt+="

The narrator is $narrator. Adjust the tone and perspective accordingly."
  fi
  
  echo "$prompt"
}

# ==============================================================================
# Context Management
# ==============================================================================

init_context() {
  mkdir -p "$temp_dir"
  : > "$temp_dir/script_context.txt"
  : > "$temp_dir/visual_notes.txt"
}

load_research_context() {
  local research_file="$1"
  local context=""
  
  if [[ -f "$research_file" ]]; then
    # Extract key insights from research
    context=$(grep -E "^##|^###|^-|Key Concepts|Historical|Cross-Cultural|Contemporary|Critical" "$research_file" | head -1000)
  fi
  
  # Also load any existing dharma content
  local dharma_files=("$reference_dir"/cot-dharma*.md "$reference_dir"/dharma-research*.md)
  for file in "${dharma_files[@]}"; do
    if [[ -f "$file" ]] && [[ "$file" != "$research_file" ]]; then
      # Add summary from other files
      context+=$'\n\n'"[Additional context from $(basename "$file")]"$'\n'
      context+=$(head -500 "$file")
      break  # Just one additional file
    fi
  done
  
  echo "$context"
}

# ==============================================================================
# Script Generation
# ==============================================================================

generate_section() {
  local section_id="$1"
  local title="$2"
  local notes="$3"
  local style="$4"
  local previous_context="$5"
  local system_prompt="$6"
  
  # Build the prompt
  local prompt="Generate a video script section for: $title

Section Notes: $notes

This is for a $style-style video essay about dharma. 

Include:
1. Opening line that connects to previous section (if applicable)
2. Main content addressing the section theme
3. Specific suggestions for visuals, B-roll, or graphics
4. Natural transition to next section
5. Timing notes to fit the overall video length

Write in a style appropriate for video narration - conversational but informative.

Previous context for continuity:
$previous_context"
  
  # Query LLM
  local response
  if ! response=$(dv2 -s "$system_prompt" -t "$temperature" -m "$model" -M "$max_tokens" -- "$prompt" 2>&1); then
    error "Failed to generate section: $title"
    return 1
  fi
  
  echo "$response"
}

# ==============================================================================
# Output Formatting
# ==============================================================================

format_video_script() {
  local script_file="$1"
  local output_file="$2"
  local style="$3"
  local length="$4"
  local narrator="$5"
  
  {
    echo "# Dharma Video Essay Script"
    echo
    echo "**Style:** $style | **Length:** $length | **Model:** $model"
    [[ -n "$narrator" ]] && echo "**Narrator:** $narrator"
    echo "**Generated:** $(date '+%Y-%m-%d %H:%M')"
    echo
    echo "---"
    echo
    
    # Add production notes
    echo "## Production Notes"
    echo
    case "$style" in
      documentary)
        echo "- Documentary style: balance talking head with B-roll"
        echo "- Include diverse cultural footage"
        echo "- Use graphics for concepts and definitions"
        ;;
      educational)
        echo "- Educational style: clear graphics and definitions"
        echo "- Include learning objectives upfront"
        echo "- Use animations for complex concepts"
        ;;
      narrative)
        echo "- Narrative style: personal and emotional"
        echo "- Use intimate camera work"
        echo "- Include moments of reflection"
        ;;
    esac
    echo
    echo "---"
    echo
    
    # Include the generated script
    cat "$script_file"
    
  } > "$output_file"
}

# ==============================================================================
# Main Function
# ==============================================================================

main() {
  # Parse command line arguments
  while (($#)); do
    case "$1" in
      -m|--model)         noarg "$@"; shift; model="$1" ;;
      -M|--max-tokens)    noarg "$@"; shift; max_tokens="$1" ;;
      -t|--temperature)   noarg "$@"; shift; temperature="$1" ;;
      -s|--style)         noarg "$@"; shift; video_style="$1" ;;
      -l|--length)        noarg "$@"; shift; video_length="$1" ;;
      -n|--narrator)      noarg "$@"; shift; narrator_name="$1" ;;
      -r|--research)      noarg "$@"; shift; research_file="$1" ;;
      -o|--output)        noarg "$@"; shift; output="$1" ;;
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
  case "$video_style" in
    documentary|educational|narrative) ;;
    *) die 2 "Invalid style: $video_style (use: documentary|educational|narrative)" ;;
  esac
  
  case "$video_length" in
    5min|10min|15min|30min) ;;
    *) die 2 "Invalid length: $video_length (use: 5min|10min|15min|30min)" ;;
  esac
  
  # Initialize
  vinfo "Starting video essay generation (style: $video_style, length: $video_length)"
  init_context
  
  # Prepare output
  mkdir -p "$output_dir"
  local temp_script="$temp_dir/script.md"
  local output_file="$output_dir/${output}_${model}_${video_style}_${video_length}.md"
  
  # Load research context if provided
  local research_context=""
  if [[ -n "$research_file" ]] && [[ -f "$research_file" ]]; then
    vinfo "Loading research context from: $research_file"
    research_context=$(load_research_context "$research_file")
  fi
  
  # Get video structure
  local -a sections
  mapfile -t sections < <(get_video_sections "$video_style" "$video_length")
  local total_sections=${#sections[@]}
  
  if ((total_sections == 0)); then
    die 2 "No sections defined for style: $video_style, length: $video_length"
  fi
  
  vinfo "Generating $total_sections sections for $video_length $video_style video"
  
  # Get system prompt
  local system_prompt
  system_prompt=$(get_system_prompt "$video_style" "$narrator_name")
  
  # Add research context to system prompt if available
  if [[ -n "$research_context" ]]; then
    system_prompt+="

Research Context:
$research_context"
  fi
  
  # Generate each section
  local i=0
  local previous_context=""
  local full_script=""
  
  for section_data in "${sections[@]}"; do
    i=$((i + 1))
    
    # Parse section data
    IFS='|' read -r section_id title notes <<< "$section_data"
    
    progress "$i" "$total_sections" "$title"
    
    # Generate section
    local section_content
    section_content=$(generate_section "$section_id" "$title" "$notes" "$video_style" "$previous_context" "$system_prompt")
    
    # Add section to script
    {
      echo "## Section $i: $title"
      echo
      echo "$section_content"
      echo
      echo "---"
      echo
    } >> "$temp_script"
    
    # Update context for next section
    previous_context=$(echo "$section_content" | tail -42)
    
    # Brief pause
    sleep 0.2
  done
  
  vinfo "Formatting final script"
  
  # Format and save output
  format_video_script "$temp_script" "$output_file" "$video_style" "$video_length" "$narrator_name"
  
  vinfo "Video essay script complete!"
  vinfo "Output saved to: $output_file"
  
  # Also create a production-ready version without metadata
  local prod_file="${output_file%.md}_production.md"
  
  # Create production script by removing visual cues and formatting
  {
    # Skip header until first section
    sed -n '/^## Section 1:/,$p' "$output_file" | \
    # Remove visual/audio cues in bold brackets
    sed 's/\*\*\[[^]]*\]\*\*//g' | \
    # Remove narrator labels
    sed 's/^\*\*Narrator.*:\*\*[[:space:]]*//' | \
    sed 's/^\*\*[^:]*:\*\*[[:space:]]*//' | \
    # Clean up extra blank lines
    sed '/^[[:space:]]*$/d' | \
    # Add back single blank lines between paragraphs
    awk 'NR==1 || NF>0 {print} {if(NF==0) print ""}'
  } > "$prod_file"
  
  vinfo "Production script saved to: $prod_file"
}

# Run main function
main "$@"

#fin
