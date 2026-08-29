# Agent Dev Workflow

[中文](./README.md)

A development workflow I’ve gradually refined while working with AI coding agents.

The goal is not to make an AI write perfect code in one shot.

Instead, it is to give the agent a development process that is **traceable, interruptible, and recoverable** when working on non-trivial tasks.

I currently use this workflow mainly with Codex.

---

## Why I Built This

When I first started using coding agents, my workflow was simple:

> Tell the agent what I wanted, then let it modify the code.

That works well for small tasks.

But as tasks became more complex, I started running into problems:

* The agent started coding before fully understanding the requirements.
* Long conversations caused previously confirmed details to get lost.
* If a session was interrupted halfway through, I had to explain the context again.
* The agent sometimes claimed a task was complete without enough verification.
* For multi-step tasks, it became difficult to tell what had actually been completed.

So I started adding a set of development rules for the agent.

The basic idea is simple:

```text
Understand requirements
        ↓
Clarify uncertainties
        ↓
Break down the task
        ↓
Create a task document
        ↓
Execute
        ↓
Verify
        ↓
Record progress
```

Instead of relying on conversation history to remember progress, the agent continuously records the actual task state inside the repository.

If a session is interrupted, the next session can recover by checking the task document, Git state, and current code before continuing.

---

## Core Principles

### 1. Don't Code Before the Requirements Are Clear

For non-trivial tasks, the agent should first understand the requirements.

If anything is unclear, it should ask questions before making substantive changes.

Only after the requirements are clear should it move on to task planning and implementation.

### 2. Persist Complex Tasks to the Repository

Once the task is confirmed, the agent creates a task document:

```text
tasks/
└── YYYY-MM-DD/
    └── YYYY-MM-DD-HH-mm-ss-task-name.md
```

The task document records things such as:

* Task goals
* Confirmed requirements
* Out-of-scope items
* Task breakdown
* Dependencies
* Current status
* Acceptance criteria
* Verification results
* Actual progress
* Recovery information

### 3. Task Status Must Reflect Reality

A task is not complete simply because the code has been written.

Its status should reflect the actual state of:

* Code
* Tests
* Verification results
* Git working tree
* Human acceptance, when required

### 4. Completion Requires Verification

Before claiming that a task is complete, the agent should perform verification appropriate to the risk and scope of the change.

It should not treat:

> "This looks like it should work."

as evidence that the task is complete.

### 5. Interrupted Tasks Should Be Recoverable

Before a task is paused or a session ends, the agent records enough information to resume safely.

When work resumes, it should not blindly trust previous conversation context.

Instead, it checks:

```text
Task document
   +
Git state
   +
Current code
   +
Verification records
```

Only after confirming the actual state should development continue.

---

## Quick Start

Place `AGENTS.md` in the root directory of your project.

### Option 1: One-Command Install

Run the following command from the **root of your Git repository**. These commands install the fixed `v1.0.0` release and will not change when later commits are added to the repository.

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/hoperswz/agent-dev-workflow/v1.0.0/scripts/install.sh | bash -s -- en
```

#### Windows PowerShell

$installer = irm https://raw.githubusercontent.com/hoperswz/agent-dev-workflow/v1.0.0/scripts/install.ps1
& ([scriptblock]::Create($installer)) -Lang en

The installers support regular Git repositories and Git worktrees. They will not overwrite an existing `AGENTS.md`, and a failed download is cleaned up without leaving a partial target file.

### Option 2: Manual Installation

Download:

```text
AGENTS.en.md
```

Copy it to your project root and rename it to:

```text
AGENTS.md
```

Your project should then look something like:

```text
your-project/
├── AGENTS.md
├── src/
├── ...
└── .git/
```

---

## Usage

Once `AGENTS.md` is installed, you don't need a special prompt to start using the workflow.

Just give your coding agent a development task as usual.

For example:

```text
Add paginated login history queries to the user module.
```

Simple changes can be handled directly.

For more complex tasks, the agent follows the workflow defined in `AGENTS.md`:

```text
Understand requirements
        ↓
Identify uncertainties
        ↓
Clarify with you
        ↓
Break down the task
        ↓
Create a task document
        ↓
Implement
        ↓
Verify
        ↓
Update task state
```

If the session is interrupted, the agent can recover the task from the repository instead of relying entirely on conversation history.

---

## What This Is Not

This is not a new coding agent.

It is also not a framework intended to replace Codex, Claude Code, Cursor, or other AI coding tools.

At the moment, it is better described as:

> **A set of development conventions for working with coding agents.**

It focuses on **how an agent carries a development task from requirement to verified completion**, rather than how the underlying model generates code.

---

## Simple Tasks

Not every change needs a task document.

Examples include:

* Fixing a typo
* Changing a clearly defined configuration value
* Small UI or styling adjustments
* Small, well-defined code changes

These can usually be handled directly.

The full workflow is intended for tasks involving multiple steps, multiple modules, dependencies, requirement uncertainty, or work that would be difficult to recover after interruption.

---

## Still Evolving

This workflow comes from continuously adjusting how I use coding agents in real development work.

It is not intended to be a finished or universal "best practice."

While using it in real projects, I still find rules that are:

* Too heavy
* Unnecessary
* Distracting
* Less useful in practice than they seemed on paper

Those rules will continue to be changed or removed.

Rather than adding more and more rules, I want this project to gradually converge on:

> **A small set of rules that genuinely help coding agents complete development tasks more reliably.**

If you try it in a real project and find something that doesn't work well, Issues and PRs are welcome.

---

## License

Apache License 2.0

You may use, modify, and distribute this project under the terms of the `LICENSE` file.
