# DefiningDharma: AI-Powered Dharma Research & Content Generation

**Version:** 2.0.0 | **Status:** Production Ready | **Updated:** January 2025

> *A sophisticated Chain of Thought (CoT) content generation system exploring dharma as universal ethical frameworks across cultures through AI-powered research and video script creation.*

## 🎯 Project Overview

DefiningDharma is an advanced AI content generation platform that explores the concept of "dharma" - universal patterns of ethical living that emerge across human cultures. Using progressive, context-aware prompting with multiple LLMs, it generates comprehensive research articles and production-ready video scripts that bridge ancient wisdom traditions with modern scientific understanding.

### Core Mission
- Generate academically rigorous yet accessible content about dharma across cultures
- Bridge philosophical traditions with contemporary science (neuroscience, evolutionary psychology)
- Create educational materials for researchers, educators, and content creators
- Explore secular interpretations while respecting traditional contexts

## 🚀 Quick Start

```bash
# Generate standard dharma research
./research-dharma.sh

# Create a 10-minute educational video script
./video-essay-dharma.sh -s educational -l 10min

# Complete research-to-video pipeline
./research-dharma.sh -d comprehensive -f notes -o my-dharma-study
./video-essay-dharma.sh -s documentary -l 15min -r mdfiles/my-dharma-study_*.md
```

## 📋 Prerequisites

### Required External Tools
- **`dv2`/`dejavu2-cli`** (`/usr/local/bin/dv2`) - LLM interface with API keys configured
- **`customkb`** (`/usr/local/bin/customkb`) - Vector database queries (15K+ documents, 777K+ segments)
- **`pandoc`** - Markdown to HTML conversion
- **`yq`** - YAML processing for video scripts

### Optional
- **MySQL** - For content storage (used by `utils/cot-dharma.php`)

## 🏗️ Architecture

### Content Generation Pipeline
```
research-dharma.sh → video-essay-dharma.sh → md2html.sh → cot-dharma.php
     (research)          (video scripts)       (HTML)       (database)
```

### Project Structure
```
DefiningDharma/
├── research-dharma.sh        # Enhanced research generation (v2.0)
├── video-essay-dharma.sh     # Video script generation (v2.0)
├── journey-to-the-west.sh    # Specialized 10-min documentary
├── utils/
│   ├── logger.sh             # Centralized logging system
│   ├── md2html.sh           # Markdown to HTML converter
│   ├── setup-logrotate.sh   # Log rotation configuration
│   └── cot-dharma.php       # MySQL database updater
├── mdfiles/                  # Generated markdown content
├── htmlfiles/                # Converted HTML output
├── video-scripts/            # Production-ready scripts
└── logs/                     # Execution logs
```

## 🎓 Core Scripts

### 1. research-dharma.sh - Enhanced Research Generation
Generates comprehensive dharma research through themed investigations.

**Features:**
- **3 Depth Levels**: `quick` (6-8 questions), `standard` (12-15), `comprehensive` (18-20)
- **3 Output Formats**: `article` (narrative), `notes` (structured), `structured` (YAML)
- **8 Research Themes**: foundations, emergence, philosophy, culture, psychology, contemporary, critical, future

**Usage:**
```bash
# Quick research with GPT-4
./research-dharma.sh -d quick -m gpt-4o

# Comprehensive notes without knowledgebase
./research-dharma.sh -d comprehensive -f notes -k none

# Structured data for analysis
./research-dharma.sh -f structured -o dharma-data
```

### 2. video-essay-dharma.sh - Video Script Generation
Creates production-ready video scripts with multiple styles and lengths.

**Features:**
- **3 Styles**: `documentary` (factual), `educational` (instructional), `narrative` (story-driven)
- **4 Lengths**: `5min`, `10min`, `15min`, `30min`
- **Research Integration**: Use previous research as context
- **Dual Output**: Annotated scripts + clean production scripts

**Usage:**
```bash
# Documentary using research file
./video-essay-dharma.sh -s documentary -l 15min -r mdfiles/dharma-research_gpt-4o.md

# Educational with custom narrator
./video-essay-dharma.sh -s educational -n "Dr. Sarah Chen" -m sonnet
```

### 3. journey-to-the-west.sh - Specialized Documentary
Fixed 10-minute video with 16 predefined sections exploring dharma's journey from East to West.

**Usage:**
```bash
# Edit line 12 to change model, then run:
./journey-to-the-west.sh
```

## 🔧 Configuration

### Models Supported
- `gpt-4o` (default) - GPT-4 Optimized
- `sonnet` / `sonnet4` - Claude 3.5 Sonnet
- `o1`, `o3-mini` - OpenAI reasoning models
- `chatgpt` - GPT-3.5 Turbo

### Key Parameters
- **Temperature**: 0.2-0.3 (low for consistency)
- **Token Limits**: 8K-16K per generation
- **Knowledgebase**: 777K+ documents on applied anthropology
- **Vector Search**: 30 top-k results, 0.6 similarity threshold

### Environment Variables
```bash
# Logging configuration
export LOGFILE=/var/log/dharma.log
export LOG_LEVEL=DEBUG
export LOG_TO_STDERR=0  # Quiet mode

# Model selection (in scripts)
model='gpt-4o'
temperature='0.3'
max_tokens=16000
```

## 📊 Logging System

All scripts use centralized logging via `utils/logger.sh`:

```bash
# Set up log rotation (requires sudo)
sudo ./utils/setup-logrotate.sh

# View logs
tail -f logs/research-dharma.sh.log
tail -f /var/log/definingdharma/research-dharma.sh.log

# Test logger
./utils/test-logger.sh
```

### Log Levels
- `DEBUG` - Detailed debugging information
- `INFO` - General information messages
- `WARN` - Warning messages
- `ERROR` - Error messages

## 🌍 Philosophical Framework

The system explores dharma through multiple lenses:

### Research Themes
1. **Foundations** - Etymology, universal patterns, cognitive architecture
2. **Historical Emergence** - Axial Age, urbanization, social complexity
3. **Philosophy** - Individual vs. collective, metacognition, ethics
4. **Cross-Cultural** - Ubuntu, Buddhism, Stoicism, indigenous wisdom
5. **Psychology** - Neuroscience, evolutionary psychology, contemplative science
6. **Contemporary** - Secular translations, digital age, professional ethics
7. **Critical** - Failure modes, power dynamics, cultural appropriation
8. **Future** - AI ethics, planetary dharma, post-traditional frameworks

### Content Standards
- Academic rigor with accessible prose
- Cultural sensitivity without romanticization
- Evidence-based approach with philosophical depth
- Non-privileging stance toward secular and religious interpretations

## 💡 Common Workflows

### Academic Research Pipeline
```bash
# 1. Generate comprehensive research
./research-dharma.sh -d comprehensive -f notes -m sonnet

# 2. Convert to HTML for publication
./utils/md2html.sh mdfiles/research-dharma_sonnet.md

# 3. Update database (if using MySQL)
php utils/cot-dharma.php
```

### Educational Content Creation
```bash
# 1. Quick research overview
./research-dharma.sh -d quick -o dharma-intro

# 2. Create 5-minute educational video
./video-essay-dharma.sh -s educational -l 5min -r mdfiles/dharma-intro_*.md
```

### Documentary Production
```bash
# 1. Comprehensive research foundation
./research-dharma.sh -d comprehensive -o dharma-doc

# 2. 15-minute documentary script
./video-essay-dharma.sh -s documentary -l 15min -r mdfiles/dharma-doc_*.md

# 3. Extract clean production script
cat video-scripts/dharma-video-essay_*_production.md
```

## 🐛 Troubleshooting

### Common Issues
1. **dv2 not found** - Ensure dejavu2-cli is installed at `/usr/local/bin/dv2`
2. **Knowledgebase errors** - Check `../seculardharma.cfg` configuration
3. **HTML conversion fails** - Verify pandoc installation
4. **Model errors** - Confirm API keys are configured in dv2
5. **Permission issues** - Scripts need execute permissions (`chmod +x`)

### Debugging
```bash
# Debug research script
./utils/debug-research-dharma.sh

# Check logs for errors
grep ERROR logs/*.log

# Verify system status
customkb query ../seculardharma.cfg "test"
```

## 📁 Output Organization

```
mdfiles/
├── research-dharma_[model].md        # Research outputs
├── dharma-video-essay_[specs].md     # Video scripts
└── journey-to-the-west_[model].md    # Documentary scripts

htmlfiles/
└── *.html                            # Web-ready content

video-scripts/
└── *_production.md                   # Clean production scripts

logs/
└── [script-name].log                 # Execution logs
```

## 🔗 Related Documentation

- **PURPOSE-FUNCTIONALITY-USAGE.md** - Detailed functionality guide
- **CLAUDE.md** - Technical guidance for AI assistants
- **Parent README** - Secular Dharma Knowledgebase overview

## 📝 Notes

- Scripts use robust error handling (`set -euo pipefail`)
- Temperature is intentionally low (0.2-0.3) for consistency
- Knowledgebase queries add processing time but provide rich context
- Pandoc styles are hardcoded at `/ai/web/www/vhosts/customkb.dev/html/pandoc/`
- System leverages symbolic links to parent applied anthropology database

## 🚧 Development Status

- **Version**: 2.0.0 (Enhanced modular scripts)
- **Knowledgebase**: 15,224 documents (777,553 searchable segments)
- **Primary Model**: GPT-4o (configurable)
- **Logging**: Centralized with rotation support
- **Status**: Fully operational and production-ready

---

*This system represents a sophisticated approach to exploring universal ethical frameworks through the lens of dharma, combining academic rigor with practical content generation capabilities.*