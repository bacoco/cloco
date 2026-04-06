# CLOco — Claude + Codex Collaboration

A thin Claude Code plugin that orchestrates [SuperPowers](https://github.com/obra/superpowers) and [Codex](https://github.com/openai/codex-plugin-cc) into a unified development pipeline.

**CLOco does not reimplement anything.** It chains existing skills and adds Codex review phases + interactive decision points between them.

## What It Does

```
You describe what you want
       │
       ▼
① superpowers:brainstorming ──► Spec
       │
       ▼
② Codex reviews the spec ──► Findings
       │
       ▼
   [You decide: A/B/C/D/E]
       │
       ▼
③ superpowers:writing-plans ──► Plan
       │
       ▼
④ Codex reviews the plan ──► Findings
       │
       ▼
   [You decide: A/B/C/D/E]
       │
       ▼
⑤ superpowers:subagent-driven-development ──► Code
       │
       ▼
⑥ Codex reviews the implementation ──► Findings
       │
       ▼
   [You decide: A/B/C/D/E]
       │
       ▼
⑦ superpowers:verification-before-completion
```

At every decision point, you get intelligent options — not just yes/no:
- **A.** Integrate all findings
- **B.** Cherry-pick specific findings
- **C.** Ignore and continue
- **D.** Ask Codex to dig deeper on a specific point
- **E.** Take over yourself
- Or free-form comment

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

Restart Claude Code. SuperPowers provides brainstorming, plan writing, subagent execution, and verification.

### Codex (optional but recommended)

1. Install the CLI: `npm install -g @openai/codex`
2. Authenticate: `codex login`
3. Add to `~/.claude/settings.json`:

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

Without Codex, CLOco runs in Claude-only mode — review phases are skipped with a warning.

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

Or just describe what you want to build — CLOco triggers automatically.

## Session Files

All artifacts are tracked in `docs/cloco-sessions/YYYY-MM-DD-<slug>/`:

| File | Source | Content |
|------|--------|---------|
| `01-spec.md` | superpowers:brainstorming | Design spec |
| `02-codex-review-spec.md` | Codex | Independent spec review |
| `03-spec-v2.md` | Claude | Corrected spec (if findings integrated) |
| `04-plan.md` | superpowers:writing-plans | Implementation plan |
| `05-codex-review-plan.md` | Codex | Independent plan review |
| `06-plan-v2.md` | Claude | Corrected plan (if findings integrated) |
| `07-codex-review-impl.md` | Codex | Code review after implementation |
| `session.log` | CLOco | All decisions, timestamps, job-ids |
| `pipeline.config.md` | User | Optional verification config |

Sessions are designed to be committed to git.

## How Codex Reviews Work

Codex (GPT-5.4) is invoked via the `codex-companion.mjs` script from the Codex plugin. It runs in **foreground** mode — Claude waits for the result (2-10 minutes is normal).

Codex has full freedom to explore your codebase: reading 30-80+ files, running type checks, checking git history. Its findings are written to a markdown file and presented to you **raw, without filtering**.

Claude and Codex communicate exclusively via files in the session directory.

## License

MIT
