#!/bin/bash
set -euo pipefail

# Script identification
readonly PRG0="$(readlink -en -- "$0")"
readonly PRGDIR="${PRG0%/*}"
readonly PRG="${PRG0##*/}"

# Source the logger library
source "$PRGDIR/utils/logger.sh"

declare -- model systemprompt prompt prompt_template LF
#declare -a video_sections
declare -i max_tokens

readonly LF=$'\n'

#model=gemini-2.5-pro-preview-06-05
#model=o1-preview-2024-09-12
model=chatgpt-4o-latest
#model=sonnet
#model=o3mini
max_tokens=16000

systemprompt=$(cat <<EOT
You are an experienced YouTube video creator and dharmic researcher.

Your task is to create scripts for each section of an in-depth 10-minute video entitled "Defining Dharma: a Journey to the West"

You will be provided with some context, however you should always also look outside of the context and also refer to your own internal knowledge of the topic.

## Writing Style Guide:

  1. Tone: Academic-conversational hybrid - authoritative yet approachable. Write with
  scholarly precision but avoid jargon overload. Show cultural empathy without
  romanticizing.
  2. Sentence Construction: Mix short declarative statements with complex analytical
  sentences. Use semicolons and em dashes for nuanced explanations. Include
  parenthetical asides for context.
  3. Vocabulary: Professional terminology balanced with plain language. Include native
  terms with translations. Choose words that demonstrate cultural awareness.
  4. Structure: 4-6 sentence paragraphs with clear topic sentences. Build arguments
  progressively. Use concrete examples to illustrate abstract concepts.
  5. Content Approach: Ground theoretical points in real-world examples. Provide
  cultural context alongside facts. Include personal insights without compromising
  objectivity.
  6. Formatting: Use hierarchical headings for navigation. Include visual breaks
  (quotes, lists). Add metadata (hashtags, references) for context.

This writing style is for *guidance* only; not hard-and-fast rules.

EOT
)

prompt_template=$(cat <<EOT
video:
  video_type: "Video Essay/Documentary"
  video_title: "Defining Dharma: a Journey to the West"
  video_sections:
    - section:
        section_title: "Introduction"
        notes: |
          In the intro fit in sentences like this:
          
          'Dharma' is an often fuzzy, ill-defined word and concept, especially in the Western world where it is a relative newcomer.

          My name is Gary Dean. For the purpose of this exploration, I describe myself as an anthropologist.

          The questions I explore here are:
            What is 'dharma'?
            What is 'a' dharma?
            What is 'The' dharma?
            What exactly do we mean when we use this word?

          These are questions I have been exploring for many years, from many perspectives, including:
            human evolutionary biology
            human evolutionary psychology
            anthropology and sociology

          My research in recent years has been greatly assisted by many people, and informed by many 'giants' in many fields.

          In rough chronological order:
            Gautama Buddha
            Socrates
            Marcus Aurelius
            Niccolò Machiavelli
            Baruch Spinoza
            Arthur Schopenhauer
            Charles Darwin
            Edward Osborne Wilson
            David Sloan Wilson
            Stephen Batchelor
            Robert Sapolsky
            David Graeber
            Rupert Bozeat
            Elfie Klinger

          The above list could just be displayed rather than read out.

    - section:
        section_title: "Defining 'Dharma'"
        notes: "a short section on etomology"

    - section:
        section_title: "Beyond Etymology: __Dharma__ as an Idea"
        notes: |
          Focus on 'dharma' as an _idea_ that is embedded in many different human cultures/groups with many different names/terms.

    - section:
        section_title: "The _Concept_ of a Dharma"
        notes: |
          dharmas as frameworks for ethical living
          cognitive and evolutionary perspectives on dharmas

    - section:
        section_title: "The Ancient Dharmic Philosophers"
        notes: "Socrates, Mahavira, Gautama, Laozi"

    - section:
        section_title: "The Axial Age and the Emergence of Dharmas"
        notes: |
          response to urbanization and complexity
          responses to existential and ethical questions
          role of walls, nations, and boundaries
          the evolution of dharmas

    - section:
        section_title: "Common Characteristics of a Dharma"
        notes: "Dharmas in their many and various forms and names have common characteristics."

    - section:
        section_title: "Why Do Dharmas Exist?"
        notes: "Why do dharmas even exist? What purpose do they serve? ..."

    - section:
        section_title: "The Evolution of Dharmas"
        notes: "How do dharmas in their various forms evolve and change over time. situational."

    - section:
        section_title: "Examples of Dharmas in Human Cultures"
        notes: |
          1. Religious Dharma
          list examples, but focus on the buddhist dharma

          2. Political Dharmas
          list examples, but focus on ubuntu

          3. Occupational/Professional Dharmas
          list examples (including medieval guilds), but focus on medical dharma

          4. Military/Martial Dharmas
          list examples, but focus on bushido

    - section:
        section_title: "The Samin of Java"
        notes: "describe the dharma of the Samin"

    - section:
        section_title: "The TriDharma of Sumarah"
        notes: "describe the dharma of Sumarah"

    - section:
        section_title: "The Maori Code of Tikanga Maori"
        notes: "describe the Tikanga Maori"

    - section:
        section_title: "Inclusive Dharmas, Exclusive Dharmas"
        notes: "some dharmas are inclusive, others highly exclusive. where is the locus of compassion in these dharmas?"

    - section:
        section_title: "Dharmas as Aesthetic, Dharmas as Identity"
        notes: "people often adopt a particular dharma because it is a marker of an identity. in particular, clothing styles - western buddhist monks, arabized indonesian muslims, hare krishna's, amish, hippies."

    - section:
        section_title: "Secular Dharmas? The Journey to the West"
        notes: |
          this is the concluding section that should wrap up the journey that dharmas have taken to get to Western societies, how secular/Western dharmas might be expressed, and the forms they take now and in the future.


  instructions: |
    You will be given a prompt for a specific section topic from the video_sections, and you will create a script for that section. Include any text that should be displayed, and make suggestions for b-roll and breaks where necessary.

    - At the start of each section, display the section topic title.
    - Respond wisely to aspects of the topic that relate to dharmas, life, humanity, evolution, legacy, impermanence, and the human condition.
    - Look beyond the immediately provided context when exploring the topic.
    - Do not use a conversational tone; directly address the topic without preambles.
    - Avoid using expressions like "In conclusion..." or "In summary...".
    - Avoid repetition from previous sections.
    - Output in Markdown format.

  prompt: |
    Section: "{{TOPIC_TITLE}}"

    Notes: {{NOTES}}

    Write the script for this section now, addressing the provided section topic comprehensively and thoughtfully, in accordance with the notes and instructions.
EOT
)


# Extract the video title
video_title=$(echo "$prompt_template" | yq -r '.video.video_title')
log_info "Video Title: $video_title"

# Extract section titles and notes
section_count=$(echo "$prompt_template" | yq -r '.video.video_sections | length')
log_info "Total sections to generate: $section_count"

sections_output=''
for i in $(seq 0 $((section_count - 1))); do
  section_title=$(echo "$prompt_template" | yq -r ".video.video_sections[$i].section.section_title")
  notes=$(echo "$prompt_template" | yq -r ".video.video_sections[$i].section.notes")
  log_info "Processing section $((i+1))/$section_count: $section_title"
  
  prompt=${prompt_template/\{\{TOPIC_TITLE\}\}/"$section_title"}
  prompt=${prompt/\{\{NOTES\}\}/"$notes"}
  
  if ! output=$(dv2 -s "$systemprompt" \
      -t 0.314 -m "$model" -M "$max_tokens" \
      -r mdfiles/cot-dharma_gpt-4o.md \
      "$sections_output$prompt" 2>&1); then
    log_error "Failed to generate section: $section_title"
    log_error "Error: $output"
    exit 1
  fi
  
  log_debug "Section generated successfully"
  sections_output+="$LF$LF$output$LF$LF"
done

output_file="mdfiles/journey-to-the-west_${model}.md"
echo "$sections_output" > "$output_file"
log_info "Video script complete. Output saved to: $output_file"

#fin
