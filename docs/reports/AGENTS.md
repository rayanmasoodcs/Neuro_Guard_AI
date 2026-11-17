# NeuroGuard AI — Agent Working Rules & Guidelines

Welcome to **NeuroGuard AI**, an AI-powered healthcare and research prototype for epilepsy and seizure detection and classification.

The central research direction is:
> *"A Patient-Independent, Adaptive EEG-Based Framework for Detection and Classification of Diverse and Subtle Seizures: Design, Evaluation Protocol, and Cross-Dataset Generalization Strategy."*

All AI assistants and agents operating on this repository must strictly adhere to the following permanent rules across all missions.

---

## A. INSPECT BEFORE MODIFYING

Before modifying any existing component or file:

1. **Identify Purpose:** Understand what the component currently does and why it was built.
2. **Identify Dependents:** Trace which files, screens, services, or APIs depend on it.
3. **Identify Dependencies:** Identify all internal and external dependencies required by the component.
4. **Verify Operational State:** Check whether the component is currently working and in what context (Flutter frontend, Flask backend, SQLite/MySQL DB, ML inference pipeline).
5. **Make Minimal Safe Changes:** Make the smallest safe change necessary to achieve the specific mission goal.
6. **Test Functionality:** Rigorously verify the changed functionality and ensure no side-effects or regressions occur.

**Mandatory Rule:** Never blindly replace, overwrite, or delete existing working functionality.

---

## B. SCOPE CONTROL

Every mission must have a single, clearly defined objective.

1. **Single Focus:** Do not combine unrelated tasks into a single mission or batch of changes.
   - For example, **NEVER** combine:
     - UI redesign
     - Backend/Firebase migration
     - ML model training
     - Chatbot changes
     inside one uncontrolled change.
2. **Strict Boundary Enforcement:** If an issue, bug, refactor opportunity, or feature request is discovered that is outside the active mission scope:
   - **DO NOT IMPLEMENT IT.**
   - Document it clearly as a future task or recommendation in the final mission report.

---

## C. CODE MODIFICATION RULES

Agents must follow these strict prohibitions and development principles:

- **Do not delete working code** without clear justification and verification.
- **Do not overwrite files blindly** or replace entire files when small surgical edits suffice.
- **Do not perform destructive refactors** that disrupt existing APIs or database schemas.
- **Do not invent APIs:** Do not create fictitious endpoints that backend services do not implement.
- **Do not invent database fields or schema entities:** Coordinate schema alterations explicitly.
- **Do not invent environment variables or secrets.**
- **Do not invent Firebase collections** without explicit architectural justification and approval.
- **Do not invent ML metrics, training figures, or experiment results.**
- **Reuse Existing Architecture:** Always leverage existing models, services, helpers, and design tokens rather than creating ad-hoc redundant implementations.

---

## D. TESTING RULE

After making changes in any mission:

1. **Run Relevant Tests:** Execute unit, integration, or script tests where available.
2. **Test Directly Affected Functionality:** Verify the specific screen, endpoint, service, or model pipeline changed.
3. **Check for Regressions:** Ensure adjacent features remain functional.
4. **Report Tests Performed:** Document exactly what was executed (commands, test scripts, manual checks).
5. **Report Failures Honestly:** If a test fails or something is broken, state it plainly.

**Mandatory Rule:** Never claim that something works unless it was actually verified.

---

## E. REPORTING RULE

At the conclusion of every mission, provide a structured report containing:

1. **Mission completed:** (Status: Completed / Partially Completed / Blocked)
2. **Files inspected:** Complete list of all files read or investigated.
3. **Files changed:** Complete list of all files modified.
4. **Files created:** Complete list of all files created.
5. **Tests performed:** Specific testing procedures and execution commands.
6. **Test results:** Accurate outcomes of all tests run.
7. **Remaining issues:** Any unresolved items or edge cases.
8. **Risks discovered:** Potential technical, architectural, or safety risks discovered.
9. **Recommended next mission:** Proposed single next objective.

**Mandatory Rule:** Do not hide failures, warnings, or incomplete states.
