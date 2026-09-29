# BRAVE Breakdown: In the Know

## Brainstorm

**In the Know** is a party word game you host yourself. There are no ads, and up to 20 people can play. At the start of each round, **Insiders** get a secret word and **Imposters** get only a hint. Everyone knows the broad category.

### Roles and accounts
- **Admins** have accounts, stored as `User` records with `role` set to `admin` or `super_admin`. In the UI they're called **Hosts**. Hosting means creating and running games. The host screen, usually a laptop sharing its screen, runs the game and doesn't play.
- **Super admins** also manage users. They can search users, change roles, and create accounts from just an email.
  - Creating an account gives the super admin a **one-time setup link** (via devise_invitable, with no email sent). The person opens the link and sets their name and password, entering the password twice.
  - The seed creates `admin@example.com` / `password` as a super admin with a funny name.
- **Players** have no accounts. They join from the home page, which is the root, with a 4-character code and a name.
  - Names are unique within a game (ignoring case and extra spaces) and can be at most 16 characters.
  - Your name acts as your password for rejoining. Entering an existing name offers "I'm Sam, rejoin". That moves the player to the new phone and logs the old phone out.
- **Backup players** are chosen by the host, and there can be several. A backup phone can add more players (name and avatar) who don't have phones.
  - For reveals and votes it cycles through them: "Pass to Otter" → Reveal → Done.

### Lobby
- The host screen shows the code, a QR code and the players who have joined.
- After joining, each player picks one of 20 animal avatars. Taken animals grey out live on every phone.
- If two people tap the same animal at nearly the same time, the second sees a friendly error. A unique index guarantees each animal is used only once per game.

### Game settings (pill button groups)
- **Player cap:** 3 to 20.
- **Rounds:** 1 to 15.
- **Rotations per round:** 2, 3, 5 or 7.
- **Imposter range:** a minimum and maximum. At most 1 imposter per 3 players, rounded down, which makes 6 the highest possible.
  - The number used each round is random within the range, limited by how many players actually joined.
- **Category:** one fixed broad category, or Random, which picks a new one each round.
- **Reveal on vote out:** whether the game announces if the player voted out was an Imposter or an Insider.
- **Vote visibility:** open, showing who voted for whom with animal icons, or anonymous, where every voter shows the raccoon.
- **Pacing:** timed (discussion lasts 30s, 1m, 2m, 3m or 5m, then voting opens automatically) or manual (the host opens the vote).

### Round flow
1. **Deal:** the game draws new imposters and a new word each round, and doesn't repeat a word within a game.
2. **Reveal:** each player privately sees their word, or their hint if they're an imposter.
3. **Rotations:** each rotation is a trip around the table, then discussion, then a vote.
   - **Voting:** the options are each remaining player plus **Skip**.
   - **Closing:** the vote closes when everyone has voted or the host ends it. Anyone who hasn't voted counts as Skip.
   - **Outcome:** a tie, or Skip getting the most votes, means nobody is out.
   - **Being out:** a player who's out sees a simple "you're out" screen.
4. **Round end:**
   - **Insiders win** if every imposter is out. Every Insider gets 1 point, including those who were voted out.
   - **Imposters win** at the end of the last rotation if at least one imposter is still in. They also win right away if it's down to 1 imposter and 1 Insider, or only imposters are left. Every imposter gets 1 point.
5. **Between rounds:** the host screen shows the leaderboard, the round number and the current phase.

### Removing players
The host can remove a player through a modal, choosing **this round** or **rest of game**. It counts like being voted out.

### Words
- `config/words.json` holds a few thousand PG entries in the form `{ word, category, lang, imposter_hint }`.
- Categories are broad. Hints are narrower and sometimes misleading on purpose.

### Pages and launch script
- **How to Play** and **Rules** pages are public, and every screen has buttons to them.
- **`bin/launch`** starts production Rails, opens an ngrok **HTTP** tunnel, writes a QR code PNG for the public URL (creating or replacing it), and prints the URL.

### Look and feel
- Clean, with dark and light themes built on Optics.
- The visual identity must look nothing like Among Us or similar games.

### Out of scope for now
- A mode where Imposters get a different word instead of a hint.
- Mixing several categories in one game.
- Stats pages. The data is stored now so they can be built later.

## Approach

**Stack:** Rails 8 app created with `rails new --database=postgresql --javascript=webpack --skip-test --skip-solid`, then the `rolemodel-rails` generators: `core_setup --skip_deployable` and `saas:devise`. That gives Slim, Optics, SimpleForm, Turbo (modals, confirm, forms), flash messages, RSpec, FactoryBot and linters.
- **Styling:** CSS follows BEM (block, element, modifier) naming on top of Optics tokens.
- **Design process:** the UI is designed with /impeccable.

**Models (6 tables):**
- `User`: Devise and devise_invitable, with `role` set to `admin` or `super_admin`.
- `Game`: `host`, `code`, `status`, plus the settings above.
- `Player`: `game`, `name`, `avatar`, `token`, `backup`, `handler` (a Player), `status` (`active` or `removed`), `points`.
- `Round`: `game`, `number`, `word`, `category`, `imposter_hint`, `status`, `current_rotation`, `discussion_ends_at`, `winner`.
- `Seat`: `round`, `player`, `role` (`insider` or `imposter`), `status` (`in`, `voted_out` or `removed`), `revealed_at`.
- `Ballot`: `round`, `rotation`, `voter` (a Seat), `target` (a Seat, empty means Skip).

**Plain Ruby objects:**
- `WordBank`: reads `config/words.json`.
- `RoundDealer`: picks imposters and the word.
- `VoteTally`: counts a vote and handles Skip and ties.
- `RoundReferee`: checks win conditions and awards points.
- `JoinGameForm`: the join and rejoin form object.
- `HostScreenPresenter` and `LeaderboardPresenter`: view presenters.

**Controllers:** RESTful. Actions like starting a game or removing a player get their own small resource controllers under the `Host::` and `Admin::` namespaces, plus the player-facing `/play` controllers.

**Live updates:** Turbo Streams over Solid Cable, backed by Postgres, since the app was generated with `--skip-solid`. There's one stream per game for the host screen and lobby, and one per player for each phone.

**Tests:** test-first throughout, per /tdd. System specs cover the user flows, model specs cover validation and game rules, and service specs cover the dealer, tally and referee.

**Initial spike:** generate the app → a host creates a game → a phone joins → picks an avatar → it greys out live on a second phone and the host screen. Then prove it works over `bin/launch` and ngrok on real phones.

**Errors and recovery:**
- **Validation messages:** clear messages on every form.
- **Race conditions:** avatar picks and votes are protected by unique indexes, and the user sees a friendly message.
- **Lost phones:** rejoining by name recovers a lost phone.
- **Stuck players:** the host can end a vote early or remove a player.

## Value

- **Business:** a free party game with no ads and no 10-player limit, which you run and control.
- **Users:** games move quickly because every player uses their own phone, and backup phones mean nobody gets left out.
- **Optimize for:** speed of delivery, keeping code readable and maintainable. Ship it and adjust once people are playing.

## Estimate

**Size:** XX-Large, about 64 points or about 2 weeks. That's a lot of uncertainty stacked together, so it's split into slices below that can each ship on their own.

**Risks:**
| Risk | Likelihood | Severity | Mitigation |
|---|---|---|---|
| Action Cable over ngrok in production mode | Medium | High | Spike it first |
| Race conditions from 20 phones acting at once | High | Medium | Database constraints and row locks in the services |
| RoleModel generators assuming things that don't fit this app | Low | Low | Fix as we go |
| Quality of a few thousand hand-written words | Medium | Low | Start smaller and grow the list |

**Incremental versions:** Slice 1, a lobby with avatars, is already a working proof. Slices 2 and 3 are a playable game. Backup devices, admin tools and polish come after.

## Implementation Plan

- [ ] **Slice 0: setup.** Generate the app and starter, add Devise, add the Solid Cable config, seed the super admin, set up `bin/launch` with ngrok and the QR code.
- [ ] **Slice 1: lobby.** Host creates a game with settings, players join by code and name, and pick avatars with live greying out.
- [ ] **Slice 2: rounds.** Deal imposters and a word, private reveals, rotations, discussion timer or manual pacing.
- [ ] **Slice 3: voting.** Ballots, Skip, ties, ending a vote early, win rules, points, leaderboard, "you're out" screen, reveal-on-vote-out setting, open or anonymous votes.
- [ ] **Slice 4: backup devices.** Host assigns backups, backup phones add players and run pass-around reveals and votes.
- [ ] **Slice 5: rejoin and remove.** Rejoin by name, and the remove-player modal for this round or rest of game.
- [ ] **Slice 6: admin.** Super admin searches users and changes roles, creates users, and generates setup links. Users set their name and password on first sign in.
- [ ] **Slice 7: content.** `words.json`, How to Play and Rules pages, the PWA manifest, the README, and `app/assets/images/avatars/AVATARS.md` (done).
- [ ] **Slice 8: polish.** An /impeccable design pass with dark and light themes.
