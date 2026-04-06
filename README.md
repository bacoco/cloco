# CLOco — Claude + Codex Collaboration

A Claude Code plugin that adds Codex reviews to the [SuperPowers](https://github.com/obra/superpowers) workflow.

CLOco does not replace SuperPowers. It wraps it: same brainstorming, same plans, same execution, same verification — but between each phase, Codex independently reviews the output against your real codebase, and Claude rewrites the artifact based on the findings and your feedback.

## The Flow

**Without CLOco** (SuperPowers alone):
```
You describe → Claude brainstorms → spec → Claude writes plan → Claude executes → verify
```

**With CLOco** (SuperPowers + Codex):
```
You describe → Claude brainstorms → spec
                                      ↓
                              Codex reviews spec (2-10 min, reads 30-80+ files)
                              Codex writes findings to a file
                                      ↓
                              Claude shows you the findings
                              You react however you want:
                                "integre tout"
                                "ignore le point 2, il a tort"
                                "ajoute aussi le support de X"
                                "le point 3 est interessant, creuse"
                                ... ou n'importe quoi d'autre
                                      ↓
                              Claude reecrit la spec en tenant compte
                                      ↓
                              Claude writes plan (superpowers:writing-plans)
                                      ↓
                              Codex reviews plan → findings → you react → Claude rewrites
                                      ↓
                              Claude executes (superpowers:subagent-driven-development)
                                      ↓
                              Codex reviews the code → findings → you react → Claude fixes
                                      ↓
                              Verify (superpowers:verification-before-completion)
```

The interaction at each review point is exactly like SuperPowers normally — Claude presents findings, suggests options, you respond in natural language. The A/B/C/D/E options are suggestions, not a rigid menu.

## Prerequisites

CLOco depends on two plugins. Install them first.

### SuperPowers (required)

Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true
  },
  "extraKnownMarketplaces": {
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    }
  }
}
```

Restart Claude Code.

### Codex (optional but recommended)

```bash
npm install -g @openai/codex
codex login
```

Then add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "codex@openai-codex": true
  },
  "extraKnownMarketplaces": {
    "openai-codex": {
      "source": {
        "source": "github",
        "repo": "openai/codex-plugin-cc"
      }
    }
  }
}
```

Without Codex, CLOco runs in Claude-only mode — review phases are skipped.

## Install CLOco

```bash
git clone https://github.com/bacoco/cloco.git ~/.claude/plugins/marketplaces/cloco
```

Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "cloco@cloco": true
  }
}
```

Restart Claude Code.

## Usage

```
/pipeline
```

Or just describe what you want to build.

## What Codex Actually Does

Codex (GPT-5.4) is invoked as an independent reviewer. It:
- Reads the spec/plan/code that Claude produced
- Explores your codebase freely (30-80+ files, 2-10 minutes)
- Writes its findings to a markdown file in the session directory
- Has zero coordination with Claude — it reviews independently

Claude then reads the findings file verbatim (no filtering, no summarizing) and presents them to you. You decide what to do. Claude rewrites the artifact accordingly.

This is the same loop you already do manually when you open Codex in a separate terminal and paste findings back to Claude — CLOco just automates the file exchange.

## Session Files

```
docs/cloco-sessions/YYYY-MM-DD-<slug>/
├── 01-spec.md                  ← Claude (via superpowers:brainstorming)
├── 02-codex-review-spec.md     ← Codex findings
├── 03-spec-v2.md               ← Claude rewrites after your feedback
├── 04-plan.md                  ← Claude (via superpowers:writing-plans)
├── 05-codex-review-plan.md     ← Codex findings
├── 06-plan-v2.md               ← Claude rewrites after your feedback
├── 07-codex-review-impl.md     ← Codex reviews the actual code
├── session.log                 ← Decisions + timestamps
└── pipeline.config.md          ← Optional verification config
```

## License

MIT
