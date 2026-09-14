# KrishiSense Team Development Contract

This file prevents the four parallel ChatGPT development sessions from drifting into different architectures.

## Rule 1 — Inspect before coding
Every developer must inspect the current GitHub repository and relevant folders before creating files or changing architecture.

## Rule 2 — One system
KrishiSense has one backend, one shared data model and one API contract.

## Rule 3 — Ownership
- AdiKul: hardware + hardware-facing backend integration.
- Ninad: core backend + database + general APIs.
- Tanush: mobile app + UI/UX + API consumption.
- Tanishq: AI/ML + decision engine.

## Rule 4 — Do not duplicate another owner's work
Use interfaces/mocks when a dependency is not ready. Do not create a second implementation just to unblock yourself.

## Rule 5 — API changes
Any API/payload change must update `docs/API_CONTRACT.md` and be communicated to affected owners.

## Rule 6 — Architecture changes
Any proposed architecture change must be explicitly labelled `PROPOSED ARCHITECTURE CHANGE` in the developer's discussion/PR before implementation.

## Rule 7 — Truthful prototype status
The physical prototype currently contains one ESP32 and one soil-moisture sensor. Do not present simulated or planned sensors as physically implemented.

## Rule 8 — Dynamic nodes
Software must support multiple nodes per farm/zone. Do not hardcode the architecture to one node.

## Rule 9 — Integration order
```text
Hardware → Backend → Database → Decision Engine → Mobile App
Mobile Image → Backend → AI → Backend → Mobile App
```

## Rule 10 — Beginner-friendly progress
Each developer should work in small phases: explain → implement → run → test → document → commit → continue.

## Rule 11 — Secrets
Never commit passwords, API keys, tokens or private credentials.

## Rule 12 — Git workflow
Use feature branches and meaningful commits. Keep `main` stable. Pull requests should explain what changed, how it was tested and which shared contracts were affected.

## Standard status report
At the end of a work session, report:
- Completed
- Files changed
- Tests passed
- Current blocker
- Next step
- Any contract/architecture change
