# NeuroGuard AI — Change Control & Engineering Workflow

To maintain stability, scientific rigor, and patient safety in **NeuroGuard AI**, all future engineering missions, bug fixes, features, and refactoring efforts must follow this disciplined change-control process.

---

## THE MANDATORY CHANGE-CONTROL LIFECYCLE

Every controlled mission must execute through the following sequential workflow stages without skipping any step:

```
INSPECT
   ↓
UNDERSTAND
   ↓
IDENTIFY DEPENDENCIES
   ↓
CREATE SAFE CHANGE
   ↓
TEST
   ↓
VERIFY
   ↓
REPORT
   ↓
CHECKPOINT
```

---

## STEP-BY-STEP PROCESS BREAKDOWN

### 1. INSPECT
- Examine the relevant directory structures, source files, schemas, and configurations.
- Read existing implementations without making destructive assumptions or modifying code prematurely.
- Check current git status and existing unstaged modifications before touching files.

### 2. UNDERSTAND
- Understand the business logic, UI workflow, medical context, or ML mathematics of the component under review.
- Understand why the current code was written that way and what problems it solved.

### 3. IDENTIFY DEPENDENCIES
- Trace upstream dependencies (imported packages, database tables, environment variables, utility functions).
- Trace downstream dependents (screens using the service, backend routes consuming the model, database shims).
- Assess whether the planned change introduces breaking contract modifications across the frontend-backend boundary.

### 4. CREATE SAFE CHANGE
- Implement the smallest, most surgical modification necessary to achieve the single objective of the mission.
- Follow established project architecture, coding standards, and existing design systems.
- Never introduce speculative, unrequested, or multi-faceted bulk edits.

### 5. TEST
- Run automated unit and integration test suites if available.
- Execute affected Python scripts or endpoint tests using dedicated verification scripts.
- Run Flutter analysis (`flutter analyze` / lint checks) when modifying Dart code.

### 6. VERIFY
- Verify that the target functionality works precisely as expected under normal and edge conditions.
- Verify that adjacent features did not suffer regressions.
- Verify that no hardcoded credentials, sensitive data, or broken imports were introduced.

### 7. REPORT
- Produce an honest, transparent end-of-mission summary detailing:
  - Exact mission objective status (Completed / Partially Completed / Blocked).
  - List of files inspected, modified, and created.
  - Test suites and manual verification performed with precise results.
  - Any remaining technical debt, bugs, or risks observed.
  - Clear recommendation for the next discrete mission.

### 8. CHECKPOINT
- Ensure the repository is left in a clean, stable, and reviewable state.
- Create git commits with descriptive, atomic commit messages corresponding strictly to the completed mission scope.

---

## PROHIBITION ON UNRELATED IMPROVEMENTS

**Strict Rule on Scope Discipline:**
During a controlled mission, agents and developers must **never** introduce "drive-by" refactoring, style overhaul, or unrelated architectural improvements.

- If you encounter a separate bug, deprecation, cosmetic flaw, or optimization while working on a mission:
  - **DO NOT FIX IT** inside the active mission unless it directly blocks the current task.
  - Document the finding in the mission's **RISKS** or **REMAINING ISSUES** section.
  - Propose it as a dedicated subsequent mission.
