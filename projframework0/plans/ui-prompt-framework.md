# UI Design Engineering Prompt Framework

A repeatable system for building high-quality user interfaces with Claude Code.

---

## How to Use This Framework

**Phase 0: Setup** — Create repository and project structure  
**Phase 1: Capture** — Copy the project template below into a new file for each project  
**Phase 2: Refine** — Use the refinement prompt to have Claude interrogate your plan  
**Phase 3: Execute** — Launch with the execution prompt structure  

---

## Phase 0: Repository Setup

Before starting any project, set up version control.

### Option A: New Project from Scratch

```bash
# Create project directory
mkdir [project-name]
cd [project-name]

# Initialize git
git init

# Create initial structure
mkdir -p plans references output src

# Create the plan file
touch plans/plan.md

# Initialize with your framework (React, Next.js, etc.)
# Examples:
npm create vite@latest . -- --template react-ts
# or
npx create-next-app@latest . --typescript --tailwind --app

# Create GitHub repo and connect
gh repo create [project-name] --private --source=. --push
# or manually:
# 1. Create repo on github.com
# 2. git remote add origin git@github.com:[username]/[project-name].git
# 3. git push -u origin main
```

### Option B: Adding to Existing Repo

```bash
# Navigate to your repo
cd [existing-repo]

# Create framework structure
mkdir -p plans references

# Add plan file
touch plans/[feature-name].md
```

### Recommended .gitignore Additions

```
# Framework artifacts
references/*.png
references/*.jpg
output/drafts/

# Keep final outputs
!output/final/
```

### Commit Strategy

```bash
# After completing plan
git add plans/
git commit -m "docs: add project plan for [feature]"

# After major iterations
git commit -m "feat: [component] - [what changed]"

# Use conventional commits for clean history:
# docs: planning and documentation
# feat: new UI components
# fix: bug fixes
# refactor: code restructuring
# style: visual/CSS changes only
```

### Claude Code Integration

When starting a Claude Code session for this project:

```
I'm working in a git repository at [path].

Before making changes:
- Create a new branch: git checkout -b feat/[feature-name]
- Make atomic commits as we build

Project plan is at: plans/plan.md
```  

---

## Phase 1: Project Template

Copy everything below this line into `/plans/[project-name].md`:

```markdown
# Project: [Name]
Date: [YYYY-MM-DD]
Status: Draft | Ready | In Progress | Complete

## 1. Core Concept
**One sentence:** What are you building?
**Problem it solves:** Why does this need to exist?
**Success looks like:** How will you know it's good?

## 2. Inspiration & References

### Visual Style References
- [URL 1] — What I like: [specific element]
- [URL 2] — What I like: [specific element]
- Screenshot: [filename or description]

### Functional References  
- [URL or app] — Interaction I want to recreate: [describe]
- [URL or app] — UX pattern to borrow: [describe]

### Anti-references (what to avoid)
- [describe style or pattern you don't want]

## 3. Technical Constraints
- **Output format:** React artifact | Next.js | HTML/Tailwind | etc.
- **Dependencies allowed:** shadcn/ui, Tailwind, Framer Motion, etc.
- **Must work with:** [existing codebase, API, data shape]
- **Viewport priority:** Mobile-first | Desktop-first | Both

## 4. Scope Definition
**In scope:**
- 
- 
- 

**Explicitly out of scope:**
- 
- 

## 5. Attached Context
- [ ] PRD attached: [filename]
- [ ] Design mockups: [filename]
- [ ] Existing component code: [filename]
- [ ] Brand guidelines: [filename]

## 6. Quality Criteria
What makes this "highest quality" for this specific project?
- [ ] Animation/motion requirements
- [ ] Accessibility requirements (WCAG level)
- [ ] Performance requirements
- [ ] Responsive breakpoints needed
- [ ] Dark mode support

## 7. Open Questions
Things I'm uncertain about that need refinement:
1. 
2. 
3. 
```

---

## Phase 2: Refinement Prompt

Use this prompt with Claude Code after completing your draft plan:

```
I'm preparing to build a UI project and want you to help me refine my plan before we start building. 

Here's my current plan: [paste plan or reference file path]

Please review this as a senior design engineer would review a junior's brief. Ask me questions to clarify:

1. Ambiguities in the visual direction — what's underspecified?
2. Technical decisions that could cause problems later
3. Scope creep risks — am I trying to do too much?
4. Missing information you'd need to build this well
5. Assumptions I might be making that should be explicit

Ask me 3-5 questions, one category at a time. Wait for my answers before moving to the next category.
```

---

## Phase 3: Execution Prompt Structure

Your first build prompt should follow this structure:

```
## Project Context
[Paste your refined plan, or reference the file path]

## Style Direction
I want this to feel like [reference site/app] — specifically:
- [Visual element 1 to emulate]
- [Visual element 2 to emulate]
- [Interaction pattern to emulate]

Avoid: [anti-references]

## Technical Requirements
- Output: Single React artifact using Tailwind CSS
- Libraries available: [list]
- This needs to work as: [standalone | part of larger app]

## Build Sequence
Start with: [most important/complex component]
Then: [secondary elements]
Finally: [polish and edge cases]

## Quality Bar
Before considering this complete:
- [ ] [Specific quality criterion 1]
- [ ] [Specific quality criterion 2]
- [ ] [Specific quality criterion 3]

Build the [component name] now.
```

---

## Quick-Start Prompts

### Recreating a Reference UI
```
I want to recreate the [specific element] from [URL].

What I like about it:
- [aspect 1]
- [aspect 2]

Build this as a React artifact with Tailwind. Match the feel, not pixel-perfect. Modern, clean, production quality.
```

### Solving a Work Problem
```
Problem: [describe the UX problem]
Users: [who]
Current state: [what exists now, if anything]
Constraints: [technical/brand/timeline]

Design and build a [component type] that solves this. Output as [format]. Prioritize [key quality].
```

### Exploring an Idea
```
I have a rough idea: [concept]

Before building, help me think through:
1. What's the core interaction?
2. What's the minimum version that proves the concept?
3. What could make this feel exceptional?

Then build a prototype as a React artifact.
```

---

## Recommended File Organization

```
/projects
  /[project-name]
    plan.md          ← Your captured plan (use template above)
    prd.md           ← Attached PRD if provided
    references/      ← Screenshots, exports
    output/          ← Generated artifacts
```

---

## Key Principles

### On First Prompts
Front-load context. The model can't ask clarifying questions before generating, so give it everything it needs to make good decisions on the first pass.

### On Style References
Be specific about *what* you like:
- ❌ Weak: "I like Linear's site"
- ✅ Strong: "I like Linear's use of subtle gradients, monospace type for data, and the way cards have almost no border but clear separation"

### On Iteration
Your plan file becomes the source of truth. When you need to continue work in a new session or with a different model, the plan carries the context forward.

### On Quality
Define it explicitly each time. "High quality" means different things for:
- A data-dense dashboard (clarity, information hierarchy, scannability)
- A marketing page (polish, animation, emotional impact)
- A mobile interaction (touch targets, gesture support, performance)

---

## Style Reference Cheat Sheet

When describing visual references, consider these dimensions:

| Dimension | Questions to Answer |
|-----------|---------------------|
| **Color** | Palette range? Saturation level? Use of gradients? Dark/light mode? |
| **Typography** | Sans/serif/mono? Weight range? Size scale? Letter spacing? |
| **Spacing** | Dense or airy? Consistent rhythm? |
| **Borders & Shadows** | Hard edges or soft? Shadow depth? Border radius? |
| **Motion** | Snappy or smooth? Bounce/spring? Duration range? |
| **Density** | Information-dense or minimal? Whitespace usage? |
| **Mood** | Playful, serious, technical, warm, cold, luxurious, utilitarian? |

---

## Common Anti-Patterns to Specify

Include these in your "avoid" section when relevant:

- Generic Bootstrap/Material UI feel
- Overly rounded "SaaS blob" aesthetic
- Gratuitous animations that slow interaction
- Low contrast text
- Inconsistent spacing
- Default browser form elements
- Stock photo energy
- Cluttered with too many competing elements

---

## Checklist Before First Build Prompt

- [ ] Core concept is one clear sentence
- [ ] At least 2 visual references with specific callouts
- [ ] Output format specified
- [ ] Scope boundaries defined
- [ ] Quality criteria are measurable/observable
- [ ] Open questions resolved or marked for discussion
