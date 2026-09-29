# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
- **Host:** an admin who runs a game night from a laptop whose screen is shared on a TV or projector. They set up the game, start rounds, open and close voting, and read out results. They don't play.
- **Players:** friends in the same room, up to 20. Each joins from their own phone with a 4-letter code and a name, with no account. Phones are held privately, often in dim party lighting.
- **Backup-phone players:** people without a phone, who share one handed-around device ("Pass to Otter").
- **Super admins:** manage host accounts by handing out one-time setup links.

## Product Purpose
In the Know is a self-hosted party word game. Insiders get a secret word and imposters get only a hint. The group gives clues around the table, votes after each trip, and scores rounds. It exists because existing apps are full of ads and cap games at around 10 players. Success means a whole room is playing within a minute and nobody waits on the tech.

## Positioning
Free, self-hosted and ad-free, for up to 20 players, with backup phones so nobody is left out. The shared host screen does the storytelling while phones stay simple and private.

## Operating Context
- The host screen is viewed from across a room, so it must read at a distance.
- Phones are used one-handed, glanced at quickly, and must never leak a secret over someone's shoulder.
- Backup phones get passed hand to hand.
- The app runs on the host's laptop and is shared over an ngrok link and QR code.

## Capabilities and Constraints
- Rails with Slim, Hotwire (Turbo morph refreshes over Action Cable) and the Optics design system. CSS follows BEM and uses Optics tokens.
- Dark and light themes.
- Installable as a PWA.
- 20 animal avatars, one per player per game (art is still being drawn), plus a raccoon for anonymous votes.
- Terminology: **Insiders** and **Imposters**. A "trip" is one pass around the table.

## Brand Commitments
- Name: **In the Know**.
- Tone: playful and a bit mischievous, never competitive-aggressive or scary.
- Must look nothing like Among Us or other social-deduction games: no space or astronaut themes, no "ejected" screens, no crewmate language.

## Evidence on Hand
- Avatar art is not drawn yet. See `app/assets/images/avatars/AVATARS.md` for the list.
- The word list is `config/words.json`.
- There are no testimonials or press.

## Product Principles
1. The big screen tells the story; phones only do private things.
2. Secrets stay secret: reveals are deliberate and brief.
3. Nobody waits on the tech: every screen has one obvious next action.
4. Mistakes are recoverable: rejoin by name, change a vote, the host can remove a player.

## Accessibility & Inclusion
- Text on the host screen must be readable from across a room.
- Avatars are told apart by animal, not only by color.
- Controls are large touch targets for one-handed use.
