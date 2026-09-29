---
name: In the Know
description: A self-hosted party word game, designed as notes passed in class.
colors:
  ballpoint-blue: "hsl(229 88% 54%)"
  ballpoint-blue-deep: "hsl(229 70% 34%)"
  gel-pen-periwinkle: "hsl(229 100% 80%)"
  notebook-paper: "hsl(42 45% 97%)"
  notebook-paper-raised: "hsl(42 60% 99%)"
  sketchbook-black: "hsl(240 12% 9%)"
  sketchbook-black-raised: "hsl(240 10% 13%)"
  college-rule-blue: "hsl(205 70% 82%)"
  margin-red: "hsl(356 78% 62%)"
  highlighter-yellow: "hsl(52 100% 66%)"
  highlighter-pink: "hsl(333 100% 76%)"
  highlighter-mint: "hsl(150 72% 70%)"
  ink-on-highlight: "hsl(236 40% 14%)"
  pencil: "hsl(236 14% 30%)"
typography:
  display:
    fontFamily: "Shantell Sans, Atkinson Hyperlegible Next, cursive"
    fontSize: "clamp(3rem, 5vw, 6rem)"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "-0.02em"
    fontVariation: "'INFM' 55, 'BNCE' 10"
  headline:
    fontFamily: "Shantell Sans, Atkinson Hyperlegible Next, cursive"
    fontSize: "2.25rem"
    fontWeight: 700
    lineHeight: 1.15
  body:
    fontFamily: "Atkinson Hyperlegible Next, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Atkinson Hyperlegible Next, system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 600
rounded:
  sheet: "8px"
  button: "12px"
  sticker: "9999px"
spacing:
  rule: "2rem"
  rule-stage: "3rem"
  margin: "3.25rem"
  margin-stage: "5rem"
components:
  button-primary:
    backgroundColor: "{colors.ballpoint-blue}"
    textColor: "{colors.notebook-paper}"
    rounded: "{rounded.button}"
    height: "3.5rem"
  sheet:
    backgroundColor: "{colors.notebook-paper-raised}"
    rounded: "{rounded.sheet}"
  highlight-callout:
    backgroundColor: "{colors.highlighter-mint}"
    textColor: "{colors.ink-on-highlight}"
  critter:
    rounded: "{rounded.sticker}"
    size: "2.75rem"
---

# Design System: In the Know

## Overview

**Creative North Star: "Passed Notes"**

Every secret in In the Know is a note passed in class. The host screen is the notebook page the whole room is reading. Each phone holds a folded note you open to read, then fold before passing it on. The system is playful and a bit mischievous, never aggressive: hand lettering, highlighter swipes and tape on ruled paper.

The whole page is the material. Ruled lines and the red margin run behind every screen. Emphasis comes from highlighter blocks that own a phrase, not from glow or gradients. Dark mode isn't the light theme inverted. It's a black-paper sketchbook with gel pens, the same highlighter colors on a night page.

This deliberately looks nothing like space-themed or neon social-deduction games.

**Key Characteristics:**
- College-ruled paper with a margin line is the page background everywhere. It's a surface, not decoration.
- The hand-lettered display face (Shantell Sans) is for anything the room reads out loud. Atkinson Hyperlegible Next is for everything read up close.
- Three highlighters carry meaning: yellow for "look here", pink for imposters, mint for Insiders and wins.
- Players are round animal stickers. Each has its own sticker color, so the animal and the color both identify a player.

## Colors

Ballpoint ink and highlighters on notebook paper.

### Primary
- **Ballpoint Blue** (hsl(229 88% 54%)): primary buttons, links, focus and caret. Drives the Optics primary scale through `--op-color-primary-h/s/l`.
- **Deep Ballpoint** (hsl(229 70% 34%) light / Gel Pen Periwinkle hsl(229 100% 80%) dark): hand-lettered headings and names, via `--itk-ink-strong`.

### Secondary
- **Highlighter Yellow** (hsl(52 100% 66%)): the join code, the current trip, the score leader, text selection.
- **Highlighter Pink** (hsl(333 100% 76%)): anything about imposters, and the focus ring.
- **Highlighter Mint** (hsl(150 72% 70%)): Insiders winning, "voted", "+1 point".

### Neutral
- **Notebook Paper** (hsl(42 45% 97%)) / **Sketchbook Black** (hsl(240 12% 9%)): the page.
- **Raised Paper** (hsl(42 60% 99%) / hsl(240 10% 13%)): sheets, cards, vote choices.
- **College Rule Blue** (hsl(205 70% 82%) / hsl(240 10% 19%)): ruled lines and dividers.
- **Margin Red** (hsl(356 78% 62% / 60%)): the margin line and crossed-out names.
- **Pencil** (hsl(236 14% 30%) / hsl(236 10% 78%)): body text.

### Named Rules
**The Highlighter Rule.** Text on a highlighter is always `--itk-on-highlight` ink in both themes. A highlighter owns a whole phrase or row, never a stray accent dot.

**The Three Pens Rule.** Yellow means "look here", pink means "imposter", mint means "Insider or win". Don't swap them.

## Typography

**Display Font:** Shantell Sans (variable: `wght`, `INFM` informality, `BNCE` bounce)
**Body Font:** Atkinson Hyperlegible Next

**Character:** A friend's handwriting for everything the room reads, and a face designed for legibility for everything read up close.

### Hierarchy
- **Display** (700–800, clamp(3rem, 5vw, 6rem), 1.0): stage titles, the join code (up to 11rem), the secret word, winner banners.
- **Headline** (700, 2.25–3rem): phone titles, page titles, handoff names.
- **Title** (600, 1.2–1.5em of stage size): roster names, round bar, leaderboard names.
- **Body** (400, 1rem, 1.5): instructions, hints, rules pages (max 42rem measure).
- **Label** (600, 0.875rem): form labels and small status text.

### Named Rules
**The Read-It-Out-Loud Rule.** If the whole room reads it, set it in Shantell Sans. If one person reads it, set it in Atkinson. There are no small labels above headings, so headings carry their own weight.

## Layout

- **Page:** every screen sits on ruled paper. Content starts after the margin line (`--itk-margin-inset`, 3.25rem, or 5rem on the stage).
- **Rule gap:** 2rem on phones and 3rem on the stage. Rows like roster lines and leaderboard rows are at least one rule tall so they sit on the lines.
- **Host stage:** full width, with type scaled by `clamp()` on the viewport (base 1.4vw).
  - **Lobby:** two columns, the code and QR code on the left and the roster on the right. Below 60rem it becomes one column.
  - **Results:** a 3:2 split between the outcome and the scores.
- **Phones:** one column, at most 30rem wide, with one primary action per screen.
- **Chrome:** help links (How to play, Rules, theme) are pinned to the bottom of every screen. Host sign-in sits bottom-left on the home page.

## Elevation & Depth

Depth is physical paper: sheets lie on the page with a soft two-layer shadow, and tape holds some of them down. There are no hard offset shadows and no glow.

### Shadow Vocabulary
- **Sheet** (`box-shadow: 0 1px 2px hsl(236 30% 10% / 12%), 0 10px 24px -8px hsl(236 30% 10% / 22%)`): sheets, cards, vote choices and the QR code. Darker in dark mode.
- **Pressed ink** (`box-shadow: 0 2px 0 var(--itk-ink-strong), 0 8px 18px -8px var(--itk-ink)`): primary buttons. It shrinks to 1px when pressed.

## Shapes

- **Radius:** sheets use 8px, buttons 12px, and stickers and avatars are full circles.
- **Tilt:** hand-placed things are rotated slightly, between -2° and +2° (tape, highlighter callouts, the join code, the QR code). Anything functional stays straight.
- **Fold creases:** the secret note has a horizontal and a vertical crease through its center.

## Components

### Buttons
- **Shape:** 12px radius. Large buttons are at least 3.5rem tall and set in the hand face.
- **Primary:** a solid Ballpoint Blue sticker with the pressed-ink shadow. It moves down 1px when pressed.
- **Default:** Optics outline buttons, re-inked.

### Sheet (`.sheet`)
Raised paper with the sheet shadow. `.sheet--taped` adds a tape strip at the top and `.sheet--tilted` adds -0.6° of rotation. It pairs with Optics `.card`.

### Critter (`.critter`)
Round animal sticker. Its color comes from `--critter-hue` per animal, lighter in light mode and deeper in dark mode. Sizes run from x-small (1.875rem) to x-large (7rem).

### Secret note (`.secret`)
The signature moment. It unfolds from its top edge (`note-unfold`, 700ms, perspective rotateX plus clip-path). An imposter's hint is swiped in pink highlighter.

### Roster, leaderboard and tally
Lines written on the rules. A player who is out is crossed through in margin red. The leader is highlighted yellow. Vote tallies show voters as small stickers, or all raccoons in anonymous mode.

### Pill rows (Optics segmented control)
Every game setting is a segmented control. `.segmented-control--wrap` wraps long ranges (3–20 players, 1–15 rounds) into a grid. The imposter range highlights in yellow between its minimum and maximum.

## Do's and Don'ts

- **Do** put new screens on the ruled page and start content after the margin.
- **Do** use highlighter blocks for emphasis, following the Three Pens Rule.
- **Do** keep one obvious next action per phone screen.
- **Don't** use space themes, astronaut or crewmate imagery, "ejected" screens, or neon glow.
- **Don't** add small labels or kickers above headings.
- **Don't** use gradients on text, glassy blur, or hard offset shadows.
- **Don't** tilt controls or anything you have to read to act on. Only decoration gets tilted.
