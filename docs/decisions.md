# In the Know: how it works and why

A guide for whoever picks this project up next. It covers what the app is, how it's built, and the decisions made along the way, including the ones that were changed and why. For setup and running, see `README.md`. For the visual system, see `DESIGN.md`.

## What it is

**In the Know** is a self-hosted party word game, a re-creation of "Imposter", built because existing apps are full of ads and cap games at around 10 players.

- **Insiders** get a secret word.
- **Imposters** get only a vague hint.
- **Everyone** sees the broad category.

The group goes around the table giving clues, votes after each trip, and scores the round.

- **Host:** a laptop shared on a TV runs the game. The host sets it up and moves it along but doesn't play.
- **Players:** join on their phones with a 4-letter code and a name. They have no accounts.
- **Backup phones:** passed around for people without a phone.
- **Hosting:** the host runs `bin/launch`, which starts the app locally in production mode and opens an ngrok link anyone can join.

## Game rules (as decided)

| Rule | Decision |
|---|---|
| Players | 3–20. The host sets the cap with a slider. The cap is 20 because there are 20 animal avatars, one per player. |
| Imposters | A random number each round, within a min–max range the host picks. At most 1 per 3 players (players ÷ 3, rounded down), never more than 6. The range is limited again at deal time by who actually joined. |
| Rounds | 1–15 per game. Each round gets a new word and new imposters, and a word never repeats within a game. |
| Trips | 2, 3, 5 or 7 trips around the table per round, with a vote after every trip. |
| Voting | Vote for anyone still in, or **Skip**. You can change your vote until it closes. It closes when everyone still in has voted or the host ends it, and anyone who didn't vote counts as Skip. |
| Vote result | The most-voted player is out. A **tie** or **Skip winning** means nobody is out. |
| Imposters win right away | When it's down to **1 imposter and 1 Insider**, or **only imposters** are left. There is deliberately *no* general "imposters ≥ Insiders" rule, because the user wanted the round to keep going while the imposters could still lose. |
| Imposters win at the end | If any imposter is still in after the last trip's vote. |
| Insiders win | As soon as every imposter is out. |
| Points | 1 point to everyone on the winning side, **including players who were voted out**. Players the host removed from the round get nothing. |
| Game end | After the last round, or when the host clicks End game. Most points wins, and ties share the win. |

### Settings the host picks
- **Player cap:** a slider from 3 to 20.
- **Imposter range:** only the counts the slider allows are shown.
- **Rounds:** 1–15.
- **Trips per round:** 2, 3, 5 or 7.
- **Category:** one of them, or **Random**, which picks a new one each round.
- **Word difficulty:** any mix of Easy, Medium and Hard.
- **Votes:** open (shows who voted for whom with animal icons) or anonymous (every voter shows the raccoon).
- **Voted-out reveal:** reveal whether they were an imposter, or keep it secret.
- **Pacing:**
  - **Timed:** 30s, 1m, 2m, 3m or 5m of discussion, then voting opens automatically.
  - **Manual:** the host opens the vote.

## People and accounts

- **Admins ("hosts")** are the only people with accounts. They create and run games, and results are stored against the host.
- **Super admins** also manage users. They can search users, change roles, and create accounts.
- **New accounts:** a super admin creates an account with just an email. **No email is sent.** The super admin gets a **one-time setup link** to pass along. It expires in 7 days and can be regenerated. The new host opens it and sets a name and a password, typed twice.
  - *Changed:* first sign-in originally only needed the email. The one-time link was chosen instead so nobody who knows an email address can claim the account.
- **Seeded super admin:** `admin@example.com` / `password`, named "Sir Knows-a-Lot". The repo is public, so change that password on any real server (the user plans to do it in the console).
- **Players** join with code and name only.
  - **Names:** unique within a game (ignoring case and extra spaces), at most 16 characters.
  - **Rejoining:** your name is your rejoin password. Entering an existing name offers "I'm Mo, rejoin", which moves that player to the new phone and signs the old phone out. It also lets someone on a backup phone move to their own phone.
- **Backup phones:** the host can make any number of phones backups. A backup phone adds players (name and animal), then runs pass-around reveals and votes ("Pass the phone to Gran").
- **Removing players:** the host can remove a player for **just this round** or **the rest of the game**. It counts like being voted out, so removing the last imposter ends the round. In the lobby, removing a player just deletes them.
- **Deleting games:** any game, whether in the lobby, in progress or finished, can be deleted from the games list by typing its 4-letter code.
  - *Changed:* this first also needed an "I understand this can't be undone" checkbox. The user preferred the code alone.

## Words

- **List:** `config/words.json` has about 2,360 entries shaped `{ word, category, lang, imposter_hint, difficulty }`.
- **Categories:** 10 broad ones. Everyday, Food & Drink, Animals & Nature, Math & Science, Places & Travel, People & Jobs, Sports & Games, Pop Culture & Fun, Holidays & Events, Music & Arts.
- **Hints:** a loose nudge, enough to fake it but not enough to guess the word. For example "Hypotenuse → Algebra", "RV → Vehicle", "Pancake → Breakfast". A hint must never share a word with its answer; the build flagged 72 of those, and all were fixed.
- **Difficulty:** 0 easy, 1 medium, 2 hard. The list leans easy (about 60 / 30 / 10). The host picks any mix.
- *Changed:* the first list had 12 narrow categories and hints that gave too much away (for example "Pancake → Flat and round"). The list was rewritten, and a migration renamed the old categories in existing games.
- All words are PG.

## Tech stack

- **App:** Rails 8.1 on Ruby 4, PostgreSQL. The user chose Postgres over SQLite ("lite is not enough").
- **Starter:** generated with the **RoleModel starter** (`rolemodel-rails`): Slim, Webpack, Optics with Phosphor icons, SimpleForm, RSpec, Capybara with Playwright, FactoryBot, and Turbo.
  - `core_setup` got stuck on the icon-library prompt, so the generators were run one at a time.
  - The Devise generator's organizations and public sign-up were removed.
- **Tests:** everything was built **test-first** (the user asked for /tdd throughout): system specs for flows, plus model and service specs for rules. There are about 120 examples.
- **Accounts:** Devise and devise_invitable.
- **Live updates:** Turbo 8 **morph page refreshes** over Action Cable using the `postgresql` adapter, so no Redis is needed.
  - Broadcasts carry **no data**. Every screen re-fetches its own page, so a secret word can never be sent to the wrong phone.
  - Pages holding temporary on-screen state, like the reveal envelope, live on their own URLs without a live stream, so refreshes don't reset them.
- **Race conditions:** handled with unique indexes (one animal per game, one vote per voter per trip) and row locks around closing votes, starting discussion and dealing. The user gets friendly errors like "Otter was just taken".

### Code map
| Thing | Where |
|---|---|
| Models | `User`, `Game`, `Player`, `Round`, `Seat` (a player's role and status in one round), `Ballot` (one vote; no target means Skip) |
| Game rules | `RoundDealer` deals roles and the word, `VoteTally` counts votes, `RoundReferee` decides winners and points, `PlayerRemoval`, `GameDeletion` |
| Form objects | `JoinGameForm` (join and rejoin), `DeleteGameForm` |
| Presenters | `HostScreenPresenter`, `PhoneScreenPresenter` (which screen a phone shows, and whose turn it is on a backup phone), `LeaderboardPresenter` |
| Word list | `WordBank` reads `config/words.json` |
| Public link | `PublicUrl` reads the ngrok URL that `bin/launch` saves to `tmp/public_url` |
| Phone screens | `DevicesController#show` at `/play`, which switches partials by phase |
| Host actions | Small resource controllers under `Host::Games::*` and `Host::Players::*` (launch, rounds, rotation, ballot box, finish, deletion, backup, removal) |

### Naming
- **Roles:** "Insiders" and "Imposters". The user wanted nothing that reads like "crewmates".
- **Trip:** one pass around the table. It's a "rotation" in the code.
- **Device:** there's no Device model. A "device" is just the phone, recognized by a signed cookie holding the player's token. A backup phone is a `Player` with `backup: true`, and the players it looks after point to it through `handler_id`.
  - *Changed:* this was simplified from separate Device, Player and Seat models. The user also suggested storing round results as a JSON hash on the game; Seat rows were kept instead because votes need real rows to point at and concurrent writes would clobber a single JSON column.

## Hosting (`bin/launch`)

1. Builds assets and prepares the **production** database.
2. Starts Rails in production mode on localhost.
3. Opens an ngrok **HTTP** tunnel. HTTP rather than TCP gives an https link phones can open, a QR code that works, and the https a PWA needs.
4. Saves the public link to `tmp/public_url` and writes `join-qr.png`, replacing any old one.
5. Prints the link and a QR code in the terminal.

- **Lobby link:** the lobby's QR code and "Go to…" line use the saved link, so they work even when the host screen is on localhost.
- **Asset folders:** production assets compile into `public/packed-assets`, so they never shadow the dev build in `public/assets`. That shadowing caused confusing "my changes don't show" bugs.
- **SSL:** `force_ssl` and `assume_ssl` are off. ngrok provides the https and sends `X-Forwarded-Proto` from 127.0.0.1, a proxy Rails trusts by default.

## Design ("Passed Notes")

Chosen through the Impeccable design skill's direction round, where the user picked "Passed Notes" from several options. The full system is in `DESIGN.md`.
- **Look:** notes passed in class. Light mode is ruled notebook paper with ballpoint ink and highlighters. Dark mode is a black-paper sketchbook with gel pens.
- **Fonts:** Shantell Sans (hand-lettered) for anything the room reads. Atkinson Hyperlegible Next for text read up close.
- **Rule:** must look **nothing like Among Us** or other social-deduction games. That means no space themes, "ejected" screens or crewmate language.
- **Highlighters:** yellow means "look here", pink means "imposter", mint means "Insider or win".
- **Avatars:** 20 animals on round stickers, told apart by animal as well as color, plus a raccoon for anonymous votes. The PNGs are geometric placeholders from `script/draw_placeholder_avatars.mjs`; the user plans to draw their own with the same file names (see `app/assets/images/avatars/AVATARS.md`).
- **Player ink:** each animal has its own light and dark ink.
  - On a phone, it themes the margin strip, buttons, name and envelope address. A backup phone takes the ink of whoever it's being passed to.
  - On the host screen, it colors each player's name.
- **Envelope reveal:** the secret arrives in an envelope, with your animal as the wax seal and your name on the front.
  - Tapping the seal opens the flap. The card slides up and comes forward. "Got it" tucks it back in and slides the envelope off screen. The user loves the little hop on the seal.
  - The envelope and cards are **always light**, even in dark mode.
  - Insiders' cards are tinted in the player's ink. Imposters get a torn hot-pink scrap with an "IMPOSTER" stamp, so they stand out at a glance.
- **Peek:** during discussion you hold a button to peek at your word, and it hides when you let go.
- **Setup form:** uses pill rows (Optics segmented controls) that stretch full width. The user wanted the pill rows to look good at any count.
- **CSS:** BEM on top of Optics tokens. Project tokens use the `--itk-` prefix.
  - Optics sets **`1rem = 10px`**, so size things with that in mind.
  - `<body>` is the scroll container and `<html>` hides overflow. Don't change `.app-body` height or overflow.

## Gotchas worth knowing
- **Stale assets:** if the page looks out of date in dev or tests, check for a stale `public/assets`, then run `bin/rails assets:clobber` and `yarn build`.
- **Old servers:** leftover servers show up as `puma` processes, not "rails server".
- **Migrations:** Rails 8.1 loads `schema.rb` into an empty database, so editing an old migration won't take effect. Add a new migration.
- **Invitations:** devise_invitable's `invite!` doesn't return true when `skip_invitation` is set, and `validate_on_invite` is off. `User#valid_for_invite?` checks the email instead.
- **Live refreshes and Stimulus:** a morph refresh can connect a controller before its data attributes are filled in. The countdown handles this with `endsAtValueChanged` and ignores empty times; that was the "NaN:NaN" timer bug.

## Ideas for later
- A mode where imposters get a *different word* instead of a hint.
- Mixing several categories in one game.
- Stats pages. The data is already stored per round and seat.
- Real avatar art to replace the placeholders.
