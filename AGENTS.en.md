# General Agent Development Collaboration Guidelines

## 1. Purpose

These guidelines are intended for large development tasks. They require the Agent to fully understand the requirements, resolve uncertainties, and establish a recoverable task list before coding, then proceed according to either the execution mode explicitly specified by the Task Initiator or the default rules defined here.

The goal is to ensure that a task can be safely resumed from repository-based task documentation even after a conversation is interrupted, context is lost, or the person or Agent working on the task changes.

These guidelines currently apply only to projects managed with Git.

The **Task Initiator** is the person who creates the overall development task and has the authority to decide the execution mode, scope changes, task cancellation, and final acceptance. Unless explicitly authorized by the Task Initiator, feedback from others may only be treated as information pending confirmation and must not directly change the task scope, execution mode, acceptance result, or cancellation decision.

---

## 2. Scope

### 2.1 When This Workflow Is Required

A task is considered a large development task if any of the following applies:

* It involves multiple files, modules, services, or system layers.
* It contains multiple interdependent development steps.
* There is uncertainty around business rules, technical solutions, or acceptance criteria.
* It is expected to require phased development, verification, or acceptance.
* It would be difficult to reliably resume after interruption using conversation history alone.

### 2.2 When This Workflow May Be Skipped

Simple changes such as typo fixes, clearly defined single-point configuration changes, or minor local styling adjustments may skip the full workflow.

If it is unclear whether a task should be treated as a large task or a simple change, the Agent must first explain the basis for its judgment and ask the Task Initiator for confirmation. The Agent must not classify a task as simple merely to bypass these guidelines.

---

## 3. Core Principles

1. Understand the requirements before implementation.
2. Do not write business code or make substantive changes while unresolved questions remain.
3. After each round of clarification, restate both **Confirmed Items** and **Remaining Questions**.
4. The final task list may only be created when there are no remaining questions.
5. Tasks must be broken down from lower-level dependencies to higher-level functionality.
6. The final task list must be persisted in a Markdown task document within the repository.
7. For the overall development task represented by each task document, use one-pass execution by default unless the Task Initiator explicitly specifies otherwise. If the Task Initiator explicitly requests step-by-step confirmation, follow that mode.
8. Task status must reflect the actual state of the code, tests, and Git working tree.
9. Do not expand the task scope without authorization. Requirement changes must go through clarification again.

### 3.1 Time Recording Rules

All timestamps in task documents must use absolute time.

Do not use relative expressions such as "today", "yesterday", "just now", or "later", and do not record only a date or only a time.

Use the following format consistently:

```text
YYYY-MM-DD HH:mm:ss UTC±HH:mm
```

---

## 4. Standard Workflow

### Phase 1: Understand the Requirements

After receiving a large development request, the Agent must not begin coding immediately.

It must first:

1. Restate the goal, deliverables, and expected outcome in its own words.
2. Identify known constraints, dependencies, risks, and out-of-scope items.
3. Inspect the current repository state and relevant documentation, performing only the necessary read-only investigation.
4. Identify all unclear, ambiguous, conflicting, or potentially implementation-changing questions.

Read-only investigation may be used to discover facts and does not mean implementation has begun.

### Phase 2: Iterative Clarification

After asking the Task Initiator questions, the Agent must wait for confirmation.

After each round of answers, it must provide an updated summary containing:

#### Confirmed Items

* Summarize all requirements and constraints confirmed so far.
* Merge newly confirmed information into the complete set of conclusions rather than recording only the latest changes.
* If contradictions are found between earlier and later information, explicitly point them out and continue clarification.

#### Remaining Questions

* List all unresolved questions again.
* Remove questions that have already been resolved.
* When no questions remain, explicitly state: **"There are no remaining questions."**

As long as unresolved questions remain, the Agent must not begin coding and must not treat temporary assumptions as final requirements.

If no questions exist after the initial analysis, the Agent must still summarize the confirmed items and explicitly state **"There are no remaining questions."** It should not invent questions or wait for unnecessary additional confirmation.

### Phase 3: Break Down the Task

Once there are no remaining questions, the Agent should break down the development work from lower-level dependencies to higher-level functionality.

The recommended order is:

1. Foundational constraints, data structures, and shared contracts.
2. Low-level utilities, storage, adapters, or infrastructure.
3. Domain logic and core services.
4. APIs, interaction layers, or higher-level functionality.
5. Integration, migration, testing, documentation, and final acceptance.

Each task item must include:

* Sequence number
* Status
* Task name
* Dependencies or prerequisites
* Deliverables
* Acceptance criteria
* Verification method
* Out-of-scope items

Before persisting the task list, the Agent must validate its dependencies:

* Every dependency must exist in the active task list.
* A task must not depend on itself.
* Tasks must not form direct or indirect dependency cycles.
* Cancelled tasks must not remain dependencies of active tasks. If cancellation invalidates a dependency, the task list must be adjusted and reconfirmed first.
* Dependency validation must be repeated whenever tasks are added, removed, reordered, or their dependencies change.

### Phase 4: Create the Task Document

Once the task list has been finalized, the task document must be created before execution begins.

Task documents are stored under a directory based on the local date when the task is first created:

```text
tasks/YYYY-MM-DD/YYYY-MM-DD-HH-mm-ss-task-name.md
```

Naming rules:

* The top-level date directory uses the local date on which the task was first created, in `yyyy-MM-dd` format.
* The date in the filename uses the same initial creation date.
* The task name should be short, stable, and avoid characters invalid in filenames.
* If a task with the same name already exists in the same date directory, append `-02`, `-03`, and so on.
* Existing task documents must never be overwritten.
* If a task continues across multiple days, keep the original directory and filename. Do not move it or create a duplicate based on the new date.

The task document must contain at least:

1. Task title and creation date
2. Background and goals
3. Confirmed items
4. Remaining questions
5. Out-of-scope items
6. Execution mode
7. Task list and completion boundaries
8. Current progress
9. Verification records
10. Change log
11. Recovery entry point

If the Task Initiator does not specify an execution mode, record:

**One-pass execution (default)**

If the Task Initiator explicitly requests step-by-step confirmation, record:

**Step-by-step confirmation**

### Phase 5: Determine the Execution Mode

The execution mode is determined according to the following rules. There is no need to ask the Task Initiator an additional question solely to choose an execution mode.

1. If the Task Initiator does not specify otherwise, use **One-pass execution** by default. Execute all currently executable tasks continuously in dependency order, complete all implementation and verification the Agent can perform, and then report the results together. Tasks requiring Task Initiator acceptance enter the `?` state.
2. If the Task Initiator explicitly requests **Step-by-step confirmation**, stop after completing each task, update the task document, and wait for permission before executing the next task.

Step-by-step confirmation controls only whether execution may continue to the next task. It is not equivalent to task acceptance.

Whether Task Initiator acceptance is required is determined by the acceptance criteria of the task item.

If acceptance is required, use the `?` state.

If acceptance is not required and the task has met all completion boundaries, it may be marked `√`.

Even if a task has already been marked `√`, Step-by-step confirmation mode still requires permission from the Task Initiator before proceeding to the next task.

In One-pass execution mode, tasks are scheduled according to the following rules:

1. A task in state `×` may start when all of its prerequisites are `√`. A task in state `~` may continue. A task in state `√` requires no further execution. Tasks in state `?` or `!` are not executable.
2. If the current task cannot continue because it is in `?`, `!`, or another documented condition, the Agent should move to the next executable task whose dependencies are satisfied.
3. The Agent must not bypass, ignore, or assume incomplete dependencies are satisfied merely to continue execution.
4. When no remaining task can proceed, the Agent must update the task document, stop execution, and wait for Task Initiator confirmation or for blocking conditions to change.
5. For a task in `?`, Task Initiator confirmation means both acceptance and permission to continue. After confirmation, change the task to `√` and recalculate executable tasks.
6. For a task in `!`, permission to continue alone does not mean the blocking condition has been resolved. The Agent must verify that the unblock condition is actually satisfied before restoring the task to its pre-blocked state.

The overall task's **Current Phase** must be tracked separately from individual task item states and recalculated whenever questions, execution mode, or task states change:

1. If unresolved questions remain: `Requirement Clarification`
2. If all tasks in the active task list are `√`: `Completed`
3. If there are no remaining questions, the task document exists, and at least one executable task exists: `In Progress`
4. If no task is executable and at least one task is `?`: `Awaiting Task Initiator Confirmation`
5. If no task is executable, there is no `?`, and at least one task is `!`: `Blocked`
6. If the task is not fully complete but none of the above states applies, treat this as an invalid task list or dependency state. Set the current phase to `Blocked`, record the reason, and stop development until the task list is corrected.

The execution mode must be recorded in the task document according to these rules before coding begins.

### Phase 6: Execution and Synchronization

During execution:

* Follow the task list and dependency order strictly.
* Before making the first substantive change for a task, change its state from `×` to `~` and record the current action.
* Update task status and progress whenever a task starts, completes, awaits Task Initiator confirmation, becomes blocked, or is cancelled.
* A task may only be marked `√` after its deliverables, acceptance criteria, and verification requirements have all been satisfied.
* A task may only be marked `?` when all implementation, acceptance conditions, and verification under the Agent's control have been completed and only Task Initiator confirmation remains.
* After substantive code or configuration changes, update the current progress and verification records accordingly.
* If the task breakdown is found to be incorrect or new requirements appear, stop the affected development work and enter the change-control process.
* Do not lower acceptance standards or omit verification merely to mark a task as complete.

---

## 5. Task States

The task list uses a single **Status** field.

Do not add separate completion flags, status descriptions, owner fields, or Task Initiator confirmation columns.

Only the following five values are allowed:

| Status | Name                                 | When to Use                                                                                                                                  |
| ------ | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `√`    | Completed                            | All completion boundaries have been met; if Task Initiator confirmation is required, it has also been received                               |
| `×`    | Not Started                          | Work has not started                                                                                                                         |
| `~`    | In Progress                          | Work has started, but some implementation or verification remains                                                                            |
| `!`    | Blocked                              | Work cannot currently continue because of dependencies, permissions, environment issues, missing information, or similar conditions          |
| `?`    | Awaiting Task Initiator Confirmation | The Agent has completed implementation and self-verification and is waiting for the Task Initiator to determine whether the task is accepted |

State transitions:

```text
× Not Started → ~ In Progress → √ Completed
× Not Started → ~ In Progress → ? Awaiting Task Initiator Confirmation → √ Completed
× Not Started → ! Blocked → × Not Started
~ In Progress → ! Blocked → ~ In Progress
? Awaiting Task Initiator Confirmation → ~ In Progress
  (Task Initiator acceptance failed)
```

Additional rules:

* `×` means only that work has not started. It must not be used after substantive changes have already been made.
* Before making the first substantive change, the Agent must change the state from `×` to `~`. It must not wait until after implementation to update the state retroactively.
* For `~`, the **Current Progress** and **Recovery Entry Point** must record the completed position, modified files, unverified changes, next action, and recovery checks.
* `!` may be entered from either `×` or `~`. The **Current Progress** or **Recovery Entry Point** must record the blocking reason, unblock condition, and next step. Once unblocked, return to the state the task had before it became blocked.
* Whether Task Initiator confirmation is required must be explicitly stated in the task item's **Acceptance Criteria**. If it is not stated, confirmation is not required by default.
* `?` may only be used when the Agent has completed all implementation and verification it can perform and the acceptance criteria explicitly require Task Initiator confirmation.
* `?` may change to `√` only after Task Initiator approval. If acceptance fails, the task must return to `~`.
* Tasks that do not require Task Initiator confirmation may move directly from `~` to `√` after verification is complete.
* Cancelled tasks must be moved out of the active task list and into the **Cancelled Tasks** section of the task document. Preserve the original sequence number, task content, cancellation reason, person who made the cancellation decision (the Task Initiator), cancellation time, and impact on dependencies and the overall goal.
* After cancelling a task, re-check whether dependencies remain valid and whether the overall goal can still be completed. If there is an impact, enter the requirement change process.
* Do not use any status symbols other than the five defined above. Do not use percentages or partial-completion symbols as substitutes for task states.

Task list template:

| Status | Order | Task                   | Dependencies | Deliverables           | Acceptance Criteria       | Verification                          | Out of Scope        |
| ------ | ----: | ---------------------- | ------------ | ---------------------- | ------------------------- | ------------------------------------- | ------------------- |
| ×      |     1 | Example low-level task | None         | Clearly defined output | Clearly testable criteria | Explicit command or inspection method | Explicit exclusions |

---

## 6. Completion Boundaries

Each task's completion boundary consists of all four of the following:

1. **Deliverables** — What specifically was added, changed, or produced.
2. **Acceptance Criteria** — What objectively verifiable conditions must be satisfied for the task to be considered complete.
3. **Verification Method** — What tests, commands, checks, or evidence will be used to verify the result.
4. **Out of Scope** — What the task explicitly does not include.

All four are required.

If an item cannot be verified, the Agent must explain why before execution and have the Task Initiator confirm an alternative acceptance method.

---

## 7. Requirement Changes and Scope Control

If requirements are added, removed, or changed during development:

1. Pause the affected tasks.
2. Record the source and impact of the change in the task document's Change Log.
3. Re-summarize the Confirmed Items and Remaining Questions.
4. Once the Remaining Questions return to zero, adjust the task list, dependencies, and completion boundaries.
5. Have the Task Initiator confirm the revised task list.
6. Re-determine the execution mode if any of the trigger conditions below apply. If the Task Initiator does not specify otherwise, One-pass execution remains the default.

The execution mode must be reconsidered when:

* Tasks are added, removed, or reordered.
* Task dependencies change.
* New Task Initiator acceptance checkpoints are added.
* A previously continuous One-pass execution must be split into stages requiring pauses.
* A previously Step-by-step confirmation workflow is to be merged into continuous execution.

Changes that only correct wording or typos, and do not alter task boundaries, dependencies, acceptance checkpoints, or execution rhythm, do not require the execution mode to be reconsidered, but they must still be recorded in the Change Log.

When removing or cancelling a task, do not simply delete its history. Move it to the **Cancelled Tasks** section according to the task-state rules and re-check its impact on dependencies and the overall goal.

Do not add opportunistic optimizations, large-scale refactoring, or unrelated fixes to the current task without confirmation.

---

## 8. Interruption and Recovery

When a task is paused, blocked, or the session is about to end, the Agent must first update the task document with at least:

* Last completed task
* Current in-progress task
* Exact point reached in the current task
* Modified files
* Changes that have been made but not yet verified
* Current blocking reason
* State before becoming blocked
* Condition required to unblock
* Specific next action
* Commands to run or files to inspect when resuming

When resuming a task, the Agent must not continue based solely on the task document or conversation history.

It must first verify:

1. The current branch and Git working tree state.
2. Whether the relevant files and code match the recorded state.
3. Whether recorded tests or verification were actually completed.
4. Whether external dependencies, environment conditions, or blocking conditions have changed.

If the task document and the actual state differ, the verifiable actual state takes precedence.

The Agent must first record the discrepancy and correction in the task document before continuing development.

---

## 9. Final Delivery

Before the overall task ends, the Agent must:

1. Review the completion boundaries of every task.
2. Set each task to `√`, `×`, `~`, `!`, or `?` according to its actual state, and explain the reason and next step for every non-completed task.
3. Perform final verification appropriate to the task's risk.
4. Update the task document's verification records and recovery entry point.
5. Report to the Task Initiator what was completed, verification results, unfinished items, and remaining risks.

The overall task may only be declared complete when every task in the active task list is `√` and there are no unexplained failures or scope gaps.

`×`, `~`, `!`, and `?` are all non-completed states.

---

## 10. Task Document Template

```markdown
# Task Name

- Created At: YYYY-MM-DD HH:mm:ss UTC±HH:mm
- Current Phase: Requirement Clarification / In Progress / Blocked / Awaiting Task Initiator Confirmation / Completed
- Task Initiator: To be recorded
- Execution Mode: One-pass execution (default)

## Background and Goals

## Confirmed Items

## Remaining Questions

There are no remaining questions.

## Out of Scope

## Task List

| Status | Order | Task | Dependencies | Deliverables | Acceptance Criteria | Verification | Out of Scope |
|---|---:|---|---|---|---|---|---|
| × | 1 | Task name | None | Deliverables | Acceptance criteria | Verification method | Exclusions |

## Current Progress

## Verification Records

## Cancelled Tasks

None. When a task is cancelled, record its original sequence number, task content, cancellation reason, cancellation decision maker (Task Initiator), cancellation time, and impact.

## Change Log

## Recovery Entry Point

- Last Completed: None
- Current Task: None
- Completed Up To: None
- Modified Files: None
- Unverified Changes: None
- Blocking Reason: None
- Pre-block State: None
- Unblock Condition: None
- Next Step: Execute the first available task in dependency order
- Recovery Checks: Check Git status, relevant files, and verification records
```
