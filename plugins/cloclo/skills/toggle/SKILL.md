---
name: cloclo
description: "Toggle CLoClo on or off. Triggers: cloclo off, cloclo on, cloclo status, pause cloclo, resume cloclo, desactive cloclo, reactive cloclo"
---

# CLoClo Toggle

Parse the user's message to determine the action:

- **off / pause / desactive** → Disable CLoClo
- **on / resume / reactive** → Enable CLoClo
- **status** (or no argument) → Report current state

## Off

```bash
touch .cloclo-disabled
```

Confirm:

```
CLoClo paused. All hooks are silent. Your wiki and skills are untouched.
To resume: cloclo on
```

## On

```bash
rm -f .cloclo-disabled
```

Confirm:

```
CLoClo active. Hooks resumed — wiki state, visual verification, post-commit.
```

## Status

```bash
if [ -f .cloclo-disabled ]; then echo "PAUSED"; else echo "ACTIVE"; fi
```

Report:

```
CLoClo is [ACTIVE|PAUSED].
```

## Rules

1. Execute immediately. No confirmation needed.
2. One line of output. Don't explain what hooks do.
3. If the file already exists (off when already off), just confirm the current state.
