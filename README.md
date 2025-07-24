# Secular Dharma Knowledgebase

**Version:** 2.0.0 | **Status:** Production Ready | **Updated:** July 2025 | **License:** GPL-3.0

> *Advanced AI research platform bridging ancient wisdom with modern science for secular ethical living frameworks.*

---

## Overview

The **Secular Dharma Knowledgebase** is an AI-powered research and content generation platform that explores ethical living through secular interpretations of dharma. Built on advanced vector search technology (FAISS) with access to **15,224 documents segmented into 777,553 searchable chunks**, it serves a growing demographic of irrelgious "spiritual" individuals, academics, and professionals seeking evidence-based approaches to wisdom traditions without supernatural beliefs.

The platform addresses the growth in secular spirituality and mindfulness practice, serving academics generating scholarly content, content creators developing educational materials, mental health professionals integrating secular mindfulness approaches, and the broader secular dharma/secular Buddhism movements. Through modular research generation and video essay creation tools, users can produce comprehensive philosophical content across configurable depth levels and multiple output formats.

---

## Core Mission & Philosophy

### Purpose
To explore dharma as **universal human ethical patterns that emerge across cultures through evolutionary processes**, treating secular and religious approaches with equal validity while maintaining rigorous academic standards. The system synthesizes insights from evolutionary psychology, neuroscience, cross-cultural anthropology, and comparative philosophy to address contemporary challenges in ethical living, meaning-making, and human flourishing.

### Philosophical Framework
- **Non-privileging Approach**: Secular and religious dharmas treated with equal validity
- **Evolutionary Grounding**: Based on human biology, psychology, and cultural evolution
- **Cross-Cultural Analysis**: Examples from Ubuntu, Buddhism, Stoicism, Confucianism, indigenous traditions
- **Critical Perspective**: Examines failure modes, power dynamics, and cultural appropriation
- **Future-Oriented**: Addresses AI ethics, climate philosophy, and planetary consciousness
- **Scientific Integration**: Grounded in peer-reviewed research and established methodologies

---

## Target Audience

### Primary Demographics (Global)
- **"Spiritual but not Religious" Individuals**: 300-500 million globally (4-6.25% of world population)
- **Academic Researchers & Educators** (25-55): 15-20 million globally in relevant fields
- **Content Creators** (28-45): Expanding mindfulness and philosophy sectors
- **Mental Health Professionals** (30-55): 2-3 million integrating contemplative approaches
- **Secular Buddhism Movement Members**: Community-based practitioners and contemplatives
- **Technology Professionals**: Seeking ethical frameworks for AI development and climate response
- **Post-Religious Identity Seekers**: Navigating meaning-making beyond traditional religion

### Geographic Distribution
- **Primary Markets**: North America, Europe, developed Asia-Pacific (60% of target audience)
- **Emerging Markets**: China, India, Brazil, urban centers globally (40% growth potential)
- **High-Penetration Regions**: Scandinavia, Western Europe, North America, Oceania (15-25%)
- **Moderate-Penetration**: Southern Europe, East Asia, Urban Latin America (8-15%)

---

## Installation & Setup

### Prerequisites
- Linux system (tested on Ubuntu 24.04)
- Python 3.8+ with virtual environment support
- [customkb](https://github.com/Open-Technology-Foundation/customkb) vector database tool
- [dv2/dejavu2-cli](https://github.com/Open-Technology-Foundation/dejavu2-cli) LLM interface tool
- pandoc for markdown to HTML conversion
- yq for YAML processing

### Quick Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Open-Technology-Foundation/seculardharma
   cd seculardharma
   ```

2. Copy and configure the template:
   ```bash
   cp seculardharma.cfg.template seculardharma.cfg
   # Edit seculardharma.cfg and add your OpenAI API key
   ```

3. Set up symbolic links to knowledgebase (if using existing):
   ```bash
   ln -s /path/to/appliedanthropology/appliedanthropology.db seculardharma.db
   ln -s /path/to/appliedanthropology/appliedanthropology.faiss seculardharma.faiss
   ```

4. Note on data directories:
   - `workshops/` - Contains source documents (symlinked in dev environment)
   - `staging.text/` - Processed text cache (symlinked in dev environment)
   - `embed_data` and `embed_data.text` are legacy symlinks pointing to the above
   - **Data download**: The staging.text data can be obtained from https://yatti.id/kb/seculardharma.zip

5. Verify installation:
   ```bash
   customkb query seculardharma "test query"
   ```

---

## Repository Structure

```
seculardharma/
├── LICENSE                         # GPL-3.0 license
├── README.md                       # This file
├── CLAUDE.md                       # AI assistant instructions
├── secular_dharma_primary_prompt.md # Primary system prompt
├── seculardharma.cfg.template      # Configuration template
├── workshops/                      # Source documents (symlink → /ai/datasets/sd/sd_gpt/)
├── staging.text/                   # Processed text cache (symlink → ../appliedanthropology/embed_data.text)
├── embed_data → workshops/         # Legacy symlink for compatibility
├── embed_data.text → staging.text/ # Legacy symlink for compatibility
├── docs/                           # Documentation
│   ├── PURPOSE-FUNCTIONALITY-USAGE.md
│   ├── demographic-profile.md
│   ├── hashtags.md
│   ├── long_desc.md
│   ├── query_role.md
│   └── short_desc.md
└── DefiningDharma/                 # Content generation workspace
    ├── 0                           # → research-dharma.sh
    ├── 1                           # → journey-to-the-west.sh
    ├── 2                           # → video-essay-dharma.sh
    ├── README.md                   # DefiningDharma readme
    ├── CLAUDE.md                   # DefiningDharma AI instructions
    ├── PURPOSE-FUNCTIONALITY-USAGE.md
    ├── research-dharma.sh          # Research generation script
    ├── journey-to-the-west.sh      # Journey video script
    ├── video-essay-dharma.sh       # Video essay generation
    └── utils/                      # Utility scripts
        ├── debug-research-dharma.sh
        ├── logger.sh
        ├── md2html.sh
        ├── setup-logrotate.sh
        └── test-logger.sh
```

---

## System Architecture

### Core Technology Stack
- **Vector Database**: FAISS-based semantic search with 1024-dimension embeddings
- **Embeddings**: OpenAI text-embedding-3-large model
- **Knowledgebase**: 15,224 documents (777,553+ searchable segments) via shared architecture
- **Search Configuration**: 30 top-k results, 0.6 similarity threshold, reranking enabled
- **AI Integration**: Support for multiple LLMs (GPT-4o, Claude Sonnet, O1, etc.)

### Shared Knowledge Architecture
The system leverages symbolic links to share vector databases with applied anthropology dataset:
```
seculardharma.db → ../appliedanthropology/appliedanthropology.db
seculardharma.faiss → ../appliedanthropology/appliedanthropology.faiss
workshops/ → /ai/datasets/sd/sd_gpt/
staging.text/ → /var/lib/vectordbs/appliedanthropology/embed_data.text
embed_data → workshops/  (legacy symlink)
embed_data.text → staging.text/  (legacy symlink)
```

This design provides access to comprehensive interdisciplinary knowledge while maintaining focused philosophical lens. The `workshops/` directory contains source documents while `staging.text/` contains processed text cache.

### Required Dependencies ✅
- **customkb**: Vector database management tool (`/usr/local/bin/customkb`)
- **dv2/dejavu2-cli**: Custom LLM interface (`/usr/local/bin/dv2`) - CRITICAL dependency
- **pandoc**: Markdown to HTML conversion with custom styles
- **yq**: YAML processing for structured content
- **MySQL**: Optional database storage for essay management

---

## Core Functionality

### 1. Enhanced Research Generation (research-dharma.sh v2.0)
Generate comprehensive dharma research across **8 thematic areas** with modular design:

**Thematic Research Areas:**
1. **Foundational Concepts** - Etymology, universal patterns, cognitive basis
2. **Historical Emergence** - Axial Age, urban complexity, socio-economic pressures
3. **Philosophical Dimensions** - Individual vs. collective, metacognitive functions
4. **Cross-Cultural Analysis** - Ubuntu, indigenous wisdom, martial traditions
5. **Psychology & Neuroscience** - Brain structure, evolutionary psychology
6. **Contemporary Applications** - Secular translation, digital age challenges
7. **Critical Perspectives** - Failure modes, cultural appropriation, power dynamics
8. **Future Directions** - Planetary dharma, AI ethics, post-traditional frameworks

**Configuration Options:**
- **Depth Levels**: quick (6-8 questions), standard (12-15), comprehensive (18-20)
- **Output Formats**: article (narrative), notes (structured), structured (YAML)
- **Model Selection**: GPT-4o, Claude Sonnet, O1, O3-mini, etc.

### 2. Video Essay Generation (video-essay-dharma.sh v2.0)
Create educational video scripts with flexible styling:

**Video Styles:**
- **Documentary**: Factual, evidence-based presentation
- **Educational**: Instructional, pedagogical format
- **Narrative**: Story-driven, personal approach

**Features:**
- Dynamic durations (5/10/15/30 min) with adaptive section counts
- Research integration for coherent script development
- Production outputs (annotated + clean versions)

### 3. Legacy Content Generation
- **Chain-of-Thought Generation**: Progressive prompting with 25+ sequential prompts
- **Journey to the West Scripts**: YAML-based section management
- **Content Processing Pipeline**: md2html conversion, debugging tools

### 4. AI Research Assistant
Configured as a **Secular Dharma Research Assistant** that:
- Bridges ancient wisdom traditions with contemporary scientific understanding
- Serves the "spiritual but not religious" demographic with evidence-based approaches
- Provides rigorous academic frameworks grounded in peer-reviewed research
- Addresses contemporary challenges in ethical living and human flourishing
- Supports content creation with structured, citable material
- Balances cultural sensitivity with scholarly analysis

---

## Quick Start Guide

### System Verification
```bash
# Test knowledgebase functionality
customkb query seculardharma.cfg "test query"

# Verify database indexes and performance
customkb verify-indexes seculardharma.cfg

# Check database statistics
sqlite3 ../appliedanthropology/appliedanthropology.db "SELECT COUNT(*) FROM segments;"
```

### Research Generation Workflows
```bash
# Navigate to working directory
cd /var/lib/vectordbs/seculardharma/DefiningDharma

# Standard research article
./research-dharma.sh

# Quick research overview
./research-dharma.sh -d quick -m gpt-4o

# Comprehensive research with notes format
./research-dharma.sh -d comprehensive -f notes -m sonnet

# Structured data output for analysis
./research-dharma.sh -f structured -o dharma-data
```

### Video Essay Creation
```bash
# 10-minute documentary using research file
./video-essay-dharma.sh -s documentary -l 10min -r mdfiles/dharma-research-notes_gpt-4o.md

# Educational video with custom narrator
./video-essay-dharma.sh -s educational -n "Dr. Smith" -m sonnet

# 15-minute narrative style
./video-essay-dharma.sh -s narrative -l 15min -t 0.8
```

### Knowledgebase Queries
```bash
# Direct philosophical inquiries
customkb query seculardharma "What is secular dharma?"

# Context-only research (no AI response)
customkb query seculardharma "Buddhist ethics" --context-only

# Custom parameters for specific research
customkb query seculardharma "mindfulness research" -k 50 -t 0.3
```

### Content Processing
```bash
# Convert markdown to styled HTML
./md2html.sh mdfiles/dharma-research-notes_gpt-4o.md

# Debug script execution
./debug-research.sh

# Traditional comprehensive article generation
./0-cot-dharma.sh -m gpt-4o -M 25000
```

---

## Common Workflows

### Complete Research-to-Video Pipeline
```bash
# 1. Generate comprehensive research with structured notes
./research-dharma.sh -d comprehensive -f notes -o dharma-exploration

# 2. Create documentary video script from research
./video-essay-dharma.sh -s documentary -l 15min -r mdfiles/dharma-exploration_*.md

# 3. Convert to HTML for web publication
./md2html.sh dharma-exploration_*
```

### Academic Content Generation
```bash
# Modern modular research approach
./research-dharma.sh -d comprehensive -f notes -m sonnet

# Traditional comprehensive article
./0-cot-dharma.sh -m gpt-4o -M 25000
```

### Quick Educational Content
```bash
# Fast overview + educational video
./research-dharma.sh -d quick -m gpt-4o
./video-essay-dharma.sh -s educational -l 5min
```

---

## Output Organization

```
DefiningDharma/
├── mdfiles/              # Raw markdown outputs
│   ├── dharma-research-notes_[model].md
│   ├── cot-dharma_[model].md
│   └── journey-to-the-west_[model].md
├── htmlfiles/            # HTML versions with custom styling
├── video-scripts/        # Video essay scripts
│   └── dharma-video-essay_[model]_[style]_[length].md
├── utils/                # Supporting tools and utilities
│   ├── logger.sh         # Logging infrastructure
│   ├── md2html.sh        # Markdown to HTML conversion
│   └── debug-research-dharma.sh # Debugging tools
└── logs/                 # Execution logs
```

---

## Configuration

### Key Parameters (seculardharma.cfg)
- **Vector Model**: text-embedding-3-large (1024 dimensions)
- **Query Model**: GPT-4o with temperature 0.2335 (optimized for consistency)
- **Search Parameters**: 30 top-k results, 0.6 similarity threshold
- **Context Files**: Points to `secular_dharma_primary_prompt.md`
- **Hybrid Search**: Currently disabled (BM25 available)
- **Knowledgebase**: 15,224 documents (777,553 searchable segments) with full access

### Model Selection
- **sonnet4**: Claude 3.5 Sonnet (default for most scripts)
- **gpt-4o**: GPT-4 Optimized
- **o1**, **o3-mini**: OpenAI reasoning models
- **chatgpt**: GPT-3.5 Turbo

---

## System Status

### 🚀 Production Ready ✅
**System is FULLY OPERATIONAL.** All components have been successfully initialized and verified.

### Current Configuration Status
- **Primary Model**: GPT-4o with temperature 0.2335 (optimized for philosophical consistency)
- **Vector Model**: text-embedding-3-large producing 1024-dimensional embeddings
- **Knowledgebase**: 15,224 documents (777,553 searchable segments) accessed via symbolic link architecture
- **Search Configuration**: 30 top-k results, 0.6 similarity threshold, reranking enabled
- **Processing Mode**: CPU-based with robust error handling throughout

### System Verification Results ✅
- ✅ All database indexes present and functional
- ✅ Vector search operational with 777K+ documents
- ✅ Query system tested successfully with context retrieval
- ✅ All critical dependencies verified and accessible
- ✅ Content generation pipeline operational
- ✅ HTML conversion pipeline with custom pandoc styling

---

## Contemporary Applications

### Primary Use Cases
1. **Academic Research**: Scholarly content generation for secular ethics and philosophy
2. **Educational Content**: Course materials, videos, and workshop resources
3. **Therapeutic Applications**: Mindfulness-based interventions and psychological treatments
4. **Professional Ethics**: AI development, climate policy, business ethics frameworks
5. **Personal Development**: Identity formation, meaning-making, contemplative practice guidance

### Contemporary Focus Areas
- **Post-religious identity formation** and secular meaning-making systems
- **Evidence-based mindfulness** applications for mental health and wellness
- **AI ethics and planetary consciousness** from secular dharma perspectives
- **Professional ethics** grounded in evolutionary psychology rather than divine command
- **Critical analysis** of power dynamics and cultural appropriation in wisdom traditions
- **Secular approaches** to raising children with strong value systems
- **Building ritual, community, and tradition** outside religious institutions

---

## Performance & Technical Notes

### Performance Characteristics
- **Database Size**: 15,224 documents (777,553 searchable segments) with comprehensive interdisciplinary coverage
- **Vector Index**: FAISS-based with reranking for improved relevance
- **Temperature Setting**: Intentionally low (0.2335) for philosophical consistency
- **Error Handling**: Robust `set -euo pipefail` implementation across all scripts
- **Processing Architecture**: CPU-based with GPU acceleration support
- **Context Integration**: Rich knowledgebase queries provide deep philosophical context

### Content Standards
- Academic rigor with accessible prose suitable for diverse audiences
- Cultural sensitivity without appropriation or oversimplification
- Scientific grounding balanced with philosophical depth and nuance
- Critical analysis while maintaining respectful engagement with traditions
- Structure responses for easy academic citation and reference
- Include interdisciplinary connections across multiple fields

---

## Documentation

### Core Documentation Files
- **PURPOSE-FUNCTIONALITY-USAGE.md**: Comprehensive system analysis
- **CLAUDE.md**: Technical guidance and development instructions
- **demographic-profile.md**: Global target audience analysis
- **query_role.md**: AI assistant role definition and capabilities

### System Requirements
- **Platform**: Linux (Ubuntu 24.04.2) with CUDA support
- **Working Directory**: `/var/lib/vectordbs/seculardharma/`
- **Python**: Virtual environments with FAISS and PyTorch
- **GPU**: L4 GPU optimization for production (falls back to CPU)

---

## Contributing & Support

The Secular Dharma Knowledgebase represents a mature, production-ready platform for sophisticated philosophical content generation that successfully bridges ancient wisdom with contemporary scientific understanding. It serves the growing movement toward secular spirituality and ethical living grounded in our understanding of human nature and cultural evolution.

### Contributing
Contributions are welcome! Please feel free to submit issues and pull requests. Areas of particular interest:
- Additional source material for inclusion in data set
- Additional language models and AI integrations
- Enhanced search algorithms and relevance tuning
- New content generation templates and styles
- Cross-cultural wisdom tradition integrations
- Performance optimizations and caching improvements

### Git Workflow & Large Files
The repository includes a `.gitcommit` script that handles large directories:
- Creates split zip archives (99MB chunks) for the `staging.text/` directory
- To extract split archives: `zip -F staging.text.zip --out combined.zip && unzip combined.zip`
- Automatically commits and pushes changes (if remote is configured)

### Documentation
For technical guidance, refer to:
- **CLAUDE.md** - Development instructions and system architecture
- **PURPOSE-FUNCTIONALITY-USAGE.md** - Detailed functionality analysis
- **demographic-profile.md** - Target audience research and market analysis
- **docs/** - Additional documentation and configuration details

### License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

---

**Repository Status**: Production Ready | **Last Updated**: July 2025 | **System Version**: 2.0.0
