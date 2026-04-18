---
name: pipeline
description: Use when the user invokes /pipeline or asks to build, implement, create, or ship a feature through a structured Claude+Codex+CodeRabbit+Gemini dev cycle with autonomous review checkpoints
---

# CLoClo Pipeline

Chains SuperPowers (brainstorm, plan, execute, verify) with autonomous
reviews (Codex + CodeRabbit) and a PR-first auto-merge flow. Invokes
underlying skills; does not reimplement them.

## When to Use

`/pipeline`, "new feature", "build X", "implement Y". Not for one-liners
or reads.

## Invocation

- `/pipeline` → auto-detect, dialogue A/B/C if artifacts exist
- `/pipeline <free text>` → directive, skip dialogue (`passe au plan`,
  `le code est ecrit revois`, `refais tout`, `pas de codex`, `ship mode`)

No flags. See `references/smart-resume.md`.

## The Pipeline Flow

| # | Phase | Skill | Output |
|---|-------|-------|--------|
| 1 | Design | `superpowers:brainstorming` | `01-spec.md` |
| 2 | Review spec (auto-integrate) | `codex-review` | `02-codex-review-spec.md` |
| 3 | Plan | `superpowers:writing-plans` | `04-plan.md` |
| 4 | Review plan (auto-integrate) | `codex-review` | `05-codex-review-plan.md` |
| 4.5 | Task DAG + briefs | inline | `08-task-dag.md`, `task-briefs/` |
| 5 | Execute | `superpowers:subagent-driven-development` | commits on feature branch |
| 6 | Review impl arch (auto-integrate) | `codex-review` | `07-codex-review-impl.md` |
| 6.5 | Review impl static (opt-in) | `coderabbit-review` | `07b-coderabbit-review-impl.md` |
| 7 | Verify | `superpowers:verification-before-completion` | `09-compliance-report.md` |
| 7.5 | Visual verify (if UI) | `agent-browser` | `screenshots/` |
| 8 | Wiki ingest (auto) | inline | wiki updated |
| 9 | Open PR + multi-bot auto-integrate + auto-merge | `superpowers:finishing-a-development-branch` | PR URL, merged, branch deleted |

Full per-phase detail: `references/phases.md`.

## Core Patterns

**Confidence-First.** Every decision passes a ≥95% check. Below threshold
→ ask user, 2-3 concrete options, terminal only. See `references/confidence-first.md`.

**Auto-Integration 3 Gates.** Review findings auto-apply only when
(1) concrete patch, (2) not auth/payments/data-migration, (3) no cross-
reviewer conflict. Cap 3 for code, 2 for spec/plan.

**PR-First + Auto-Merge.** Phase 9 opens PR → waits 10 min → auto-applies
patches → re-reviews → merges with `--delete-branch` when clean.
Stack: `references/bot-stack.md`.

## Session Setup

Create `docs/cloclo-sessions/YYYY-MM-DD-<slug>/`, init `session.log`,
optional `pipeline.config.md` for project verification commands.

## References

Everything detailed lives in `references/`: `smart-resume.md` (directives),
`confidence-first.md` (ask rule), `bot-stack.md` (bot list), `phases.md`
(per-phase execution), `prerequisites.md` (auto-install),
`model-policy.md`, `retries.md`, `session-files.md`.

## Important Rules

1. Invoke underlying skills; never reimplement them.
2. Phase 1 is the only scheduled interactive phase. Confidence-First
   applies everywhere — ask when unsure, never guess.
3. Questions stay in the terminal, never on GitHub.
4. No flags, ever. Directives replace them.
5. Each phase outputs to session dir with numbered filenames.
6. Checkpoint after every phase; handoff on exit, always.
7. SuperPowers specs/plans stay in their own dirs; CLoClo copies into
   the session dir.
8. Phase 8 wiki ingest is automatic and silent; skipped if no wiki.
9. Reviews never auto-skip. Codex fails → Claude fallback. CodeRabbit
   fails → warn and continue.
10. Branch deleted on auto-merge (`--delete-branch`); kept alive on
    escalation so user can push manual fixes.
