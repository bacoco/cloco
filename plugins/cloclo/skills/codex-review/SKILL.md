---
name: codex-review
description: "Review a spec, plan, or implementation — first tries Codex (GPT-5.4), falls back to Claude subagent if unavailable. Writes findings to a file. Foreground execution."
user-invocable: false
---

# codex-review

Review a spec, plan, or implementation. Tries Codex first (independent model, explores
codebase freely). If Codex is unavailable (CLI missing, usage limits, runtime error),
falls back to a Claude subagent review. Either way, findings are written to a file
that the calling skill reads back verbatim.

## 1. Context Reception

The calling skill (typically `pipeline`) passes:

| Parameter     | Required for          | Description                                      |
|---------------|-----------------------|--------------------------------------------------|
| `review_type` | all                   | One of `spec`, `plan`, `impl`                    |
| `session_dir` | all                   | Absolute path to the session directory            |
| `input_file`  | all                   | Path to the artifact under review                |
| `output_file` | all                   | Path where the review must be written             |
| `spec_path`   | `plan`, `impl`        | Path to the approved spec                        |
| `plan_path`   | `impl`                | Path to the approved plan                        |
| `base_ref`    | `impl`                | Git ref before implementation started            |
| `commit_list` | `impl`                | Space-separated commit hashes to review          |

## 2. Try Codex First

### Prerequisites

```bash
# Check Codex CLI
command -v codex &>/dev/null || CODEX_UNAVAILABLE=1

# Find companion script
CODEX_COMPANION_PATH="${CODEX_COMPANION_PATH:-$(find ~/.claude/plugins -name codex-companion.mjs -path '*/codex/scripts/*' 2>/dev/null | head -1)}"
[ -z "$CODEX_COMPANION_PATH" ] && CODEX_UNAVAILABLE=1

# Auth is managed by Codex CLI internally — do NOT check codex whoami or OPENAI_API_KEY
```

### Prompt Construction

1. Read the template: `${SKILL_DIR}/templates/review-{review_type}-prompt.md`
2. Replace placeholders: `{{SPEC_PATH}}`, `{{PLAN_PATH}}`, `{{OUTPUT_PATH}}`, `{{BASE_REF}}`, `{{COMMIT_LIST}}`
3. Write resolved prompt to `/tmp/cloclo-codex-prompt-$(date +%s).md`

### Execution (FOREGROUND)

```bash
node "$CODEX_COMPANION_PATH" task --write --prompt-file /tmp/cloclo-codex-prompt-{timestamp}.md
```

- Print: "Codex is reviewing... (this takes 2-10 minutes)"
- Block until exit
- Delete temp prompt after completion

### Result Check

If `output_file` exists and is non-empty → **Codex succeeded**. Return raw content.

If Codex failed (exit code non-zero, output empty, usage limit error) → **fall through to Claude fallback** (section 3).

Log to `session.log` either way.

## 3. Claude Fallback

When Codex is unavailable or fails, dispatch a Claude subagent to do the review.

**Why this works:** The subagent has fresh context (hasn't seen the conversation), reads
the actual files, and catches real bugs. Less independent than Codex (same model family),
but far better than skipping the review.

### Dispatch by review_type

**For `spec` review:**

```
Agent(
  subagent_type: "superpowers:code-reviewer",
  prompt: "Review this implementation spec: {input_file}

  You are a senior reviewer. Read the spec, explore the codebase, and verify:
  - Every file, function, and hook mentioned actually exists
  - The architecture is feasible
  - Edge cases and fallbacks are defined
  - No contradictions between sections

  Write your review to: {output_file}

  Format: Verdict, then findings with severity (P0/P1/P2), file refs, and line numbers."
)
```

**For `plan` review:**

```
Agent(
  subagent_type: "superpowers:code-reviewer",
  prompt: "Review this implementation plan: {input_file}
  Based on the spec: {spec_path}

  You are a senior reviewer. Read the plan, explore the codebase, and verify:
  - Every file/function/hook mentioned exists and has the right signature
  - The plan covers everything the spec requires
  - Task order has no circular dependencies
  - Code snippets will compile against real types
  - Edge cases from the spec have matching implementation steps

  Write your review to: {output_file}

  Format: Verdict, then findings with severity (P0/P1/P2), file refs, and line numbers."
)
```

**For `impl` review:**

```
Agent(
  subagent_type: "superpowers:code-reviewer",
  prompt: "Review this implementation against its spec and plan.

  Spec: {spec_path}
  Plan: {plan_path}
  Base ref: {base_ref}
  Commits: {commit_list}

  Run git diff {base_ref}..HEAD to see all changes. Read each modified file in full.
  Verify:
  - Implementation matches the spec
  - Hook signatures, field names, and types are correct
  - Fallbacks defined for empty/error states
  - No regressions in modified files
  - Mobile responsive if UI was touched

  Write your review to: {output_file}

  Format: Verdict, then findings with severity (P0/P1/P2), file refs, and line numbers."
)
```

### Result Handling (same for both Codex and Claude)

- Read `output_file` in its entirety
- Return raw content to the calling skill — no summarization, no reformatting
- Log to `session.log`:
  ```
  [timestamp] Review (type=spec, engine=codex|claude) complete: /path/to/output_file
  ```

## 4. Important Rules

- **NEVER summarize or filter findings.** Raw file, as written by the reviewer.
- **NEVER re-run automatically.** User decides via decision points A-E.
- **NEVER skip reviews entirely.** If Codex fails, Claude reviews. If Claude fails, warn and return.
- **Foreground ONLY.** No background promises, no polling loops.
- **Clean up temp files.** Codex prompt in `/tmp/` is deleted. Output in `session_dir/` is permanent.
- **Log which engine was used.** The calling skill and the user should know if the review came from Codex or Claude.
