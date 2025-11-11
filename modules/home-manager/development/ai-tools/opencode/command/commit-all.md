---
description: Commit all changes
agent: build
---

Stage all files and then create a comprehensive commit message:

## Stage All Files

!`git add .`

## Current Status

!`git status`

## Recent History

!`git log --oneline -20`

## Staged Changes

!`git diff --staged`

## Instructions

Synthesize all staged files into a single, professional commit message. Follow
conventional commit format: `<type>(<scope>): <description>`. Add bullet points
for detailed changes if needed.

Consider:

- What are the main changes being made?
- Are there any JIRA tickets mentioned in branch name or commits?
- Group related changes logically
- Keep the description concise but meaningful
- Use imperative mood (e.g., "add" not "added")

Then execute: `git commit -m "your message"`
