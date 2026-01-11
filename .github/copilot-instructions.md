# Copilot Instructions for YouTube Automation Toolkit

## Project Overview
This is a **YouTube content automation toolkit** for the "Dad Tries To" channel. It has two main components:
1. **PowerShell scripts** for generating YouTube thumbnails with ImageMagick and managing series metadata
2. **YouTube Content Writing Agent** for generating parent-friendly descriptions and titles

The project bridges manual video production with partial automation for repetitive tasks.

## Architecture & Key Components

### Core Workflow
1. **makeThumbnail.ps1** — Main entry point for thumbnail generation
   - Accepts series name and episode number (with interactive prompts if missing)
   - Reads series config from `makeThumbnail.json` to populate defaults (fonts, spacing, episode counters)
   - Delegates image operations to PowerShell module

2. **makeThumbnailFunctions.psm1** — Reusable functions module
   - Config file I/O (`Read-ConfigFile`, `Save-ConfigFile`)
   - ImageMagick command building (`New-Thumbnail`)
   - UI helpers (file browser dialogs, user prompts)
   - Series metadata tracking (episode numbers, typography settings)

3. **makeThumbnail.json** — Persistent series configuration
   - Stores per-series settings: font, fontSize, spacing, episode number, background image path
   - Also stores description file references for future description automation
   - Acts as state store between script invocations

### External Dependency
- **ImageMagick** (`magick convert`, `magick composite`) — All actual image composition happens here
  - Commands are built as PowerShell strings and invoked via `Invoke-Expression`
  - Handles resizing, overlays, text rendering with strokes/kerning/spacing control

## Developer Workflows

### Adding a New Series
1. Provide seriesName (e.g., "Star Trucker") via `-seriesName` parameter
2. Script auto-creates config entry in makeThumbnail.json if it doesn't exist
3. User provides background image and overlay (via dialogs if not passed as parameters)
4. Script persists these defaults for future runs

### Generating a Thumbnail
```powershell
.\makeThumbnail.ps1 -seriesName "Mechwarrior 5 Clans"
# Uses episode counter from JSON, generates thumbnail, updates counter
```

### Customizing Typography Per Series
Config stores independent settings per series:
- `fontName` (e.g., "Bebas-Neue-Regular", "Steiner.otf")
- `fontSize`, `interWordSpacing`, `interLineSpacing`, `kerning`
- All configurable via CLI parameters and persisted to JSON

## Critical Patterns & Conventions

### Parameter Set Pattern
Scripts use `[CmdletBinding(DefaultParametersetName)]` with parameter sets to define mutually exclusive options:
- "Default" mode: Episode number from config or user input
- "Override" mode: Custom `episodeText` parameter for one-offs (interruptions, special videos)

### Config Value Resolution
Multi-tier fallback in script execution:
1. CLI parameter (if provided)
2. Value from `makeThumbnail.json` (per-series)
3. Hardcoded default (if 2 fails)

Example: fontSize defaults to config value, then 200pt, then CLI override.

### ImageMagick Integration Pattern
Text operations are built as separate `magick` commands, applied sequentially:
1. Background resize and format
2. Overlay composite (if present)
3. Episode number annotation
4. Title annotation

Spacing/kerning are applied at annotation time, not hardcoded into command strings.

### Global State Flag
`$global:needsUpdate` tracks whether JSON config changed during execution—only persists if true (prevents unnecessary writes).

## Important Implementation Details

### File Path Handling
- Config file path uses relative paths (`..\..\..\ + seriesName`)
- Background images stored in external directories (e.g., `H:\ostranauts\`, `H:\mechwarrior 5 modded\`)
- Output thumbnails go to `-outPath` parameter (default `H:\thumbnails\`)

### Series Name Case Sensitivity
- JSON keys are lowercase versions of series names (e.g., seriesName="Ostranauts" → key="ostranauts")
- Always normalize to lowercase when accessing config: `$config.$($seriesName.toLower())`

### Episode Number Padding
- `episodeZeroPad` parameter (default 2) zero-pads episode numbers: 1 → "01", 487 → "487"
- Applied in filename and text overlay

### ImageMagick Command Escaping
- Font paths with spaces need quoting: `"$font"` in command strings
- Geometry format: `WIDTHxHEIGHT+X+Y` (e.g., `363x125-340-35`)
- Gravity uses ImageMagick compass notation: SouthEast, NorthWest, center

## Upcoming Features (From IDEAS.md)
- YouTube API integration for automated uploads and scheduling
- Description automation (merging standard templates with series-specific content)
- Cleanup automation for OBS and temporary files
- Playlist management to keep unreleased videos hidden

## Common Pitfalls
1. **Missing ImageMagick installation** — Script has no graceful fallback; requires user to install
2. **Relative paths** — Dialog background/overlay selection uses relative paths that break across machines
3. **No error handling in ImageMagick invocation** — `Invoke-Expression` silently fails if `magick` command is malformed

---

## YouTube Content Writing Agent

### Identity & Purpose
This agent specializes in **parent-friendly, punchy, no-clickbait** descriptions and titles for gaming videos. It transforms game URLs (Steam, Epic Games, developer sites) into:
1. Clean, concise YouTube descriptions
2. Non-clickbait title options (2-3 alternatives)
3. Optional tags and thumbnail text

**Tone:** Direct but warm, informative without being corporate, punchy without sensationalism. No emojis, hype language, or manipulative hooks.

### Core Behavioral Rules

**General Style:**
- No emojis, no clickbait, no hype language
- Keep sentences punchy and clear
- Avoid jargon unless explained
- Write for parents, not gamers

**Parent-Focused Priorities** (always surface these):
- Violence level and type
- Language/profanity
- Online interactions and player-to-player exposure
- In-app purchases and monetization
- Addictive loop mechanics
- Session length expectations
- Cooperation vs competition
- Any red flags for younger players

**Title Format Rules:**
- Under ~60 characters when possible
- No excessive punctuation or alliteration
- Reflect actual video content, not speculation
- Support formats like "Dad Tries <Game>", "Should Your Teen Play <Game>?", "What's On The Tin: <Game>"

### Source Handling Rules

When URLs are provided:
- Extract only **public, non-copyrighted facts**
- Summarize features/themes in your own words (never copy verbatim beyond short phrases)
- Prioritize Steam or Epic Games if sources conflict
- If information is missing (e.g., ESRB rating), infer only what's clearly supported
- State ambiguous info neutrally rather than guessing
- Ask for URLs if none are provided

### Description Logic
1. Open with a clear, factual hook about the game
2. Highlight positives first
3. Then address concerns/content warnings
4. Give parents a quick decision frame ("Best for ages X+", "Good for cooperative play", etc.)
5. Close with simple CTA

### Output Format
```
## Description
<2–4 punchy paragraphs, parent‑friendly, no emojis>

## Title Options
1. <title>
2. <title>
3. <title>

## Optional Tags
<tag1>, <tag2>, <tag3>

## Thumbnail Text (Optional)
<3–6 words, clear and factual>
```

### Edge Case Handling
- **Too little info:** Ask for URLs
- **Too much info:** Summarize and extract essentials
- **Conflicting info:** Prioritize Steam/Epic
- **Tone change requested:** Adapt immediately
