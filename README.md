# In the Know

A party word game you host yourself. No ads, and up to 20 players.

Everyone gets the same secret word, except the **imposters**, who only get a hint. Go around the table giving clues, vote after each trip, and see if the **Insiders** catch the imposters before they blend in.

- **The host screen** (your laptop on the TV) runs the game. The host doesn't play.
- **Phones** join with a 4-letter code and a name. No account needed.
- **Backup phones** get passed around for people without a phone.
- **How to Play** and **Rules** pages are linked from every screen.

## What you need

| Tool | Version | Notes |
|---|---|---|
| Ruby | see `.ruby-version` | |
| Node + Yarn | see `.node-version`; Yarn 4 via `corepack enable` | Builds CSS/JS with Webpack |
| PostgreSQL | 14+ | [Postgres.app](https://postgresapp.com) is easiest on a Mac |
| ngrok | any | `brew install ngrok`, then `ngrok config add-authtoken <token>` (free account) |

## Set up once

```sh
bundle install
yarn install
bin/rails db:prepare   # creates the databases and seeds the super admin
```

The seed creates a super admin account:

- **Email:** `admin@example.com`
- **Password:** `password`
- **Name:** Sir Knows-a-Lot

Change the password after your first sign in.

## Host a game night

```sh
bin/launch
```

This will:

1. Build assets and prepare the **production** database, seeding it the first time.
2. Start Rails in production mode on `http://localhost:3000`.
3. Open an **ngrok HTTPS tunnel** to it.
4. Write **`join-qr.png`** in the project root with the public link, replacing any old one, and open it.
5. Print the public link and a terminal QR code so you can also send the link to remote players.

Options: `bin/launch --port 3001` and `bin/launch --skip-build` (reuses the last asset build). Press **Ctrl-C** to stop everything. Logs are in `log/launch.log` and `log/ngrok.log`.

Then:

1. Open the printed link on your laptop, click **Host sign in** (bottom left), and sign in.
2. Click **New game**, pick the settings, and put the lobby on the TV. It shows the code and a QR code.
3. Players scan or type the code and pick an animal. The host can make any phone a **backup phone**.
4. Click **Start game** once at least 3 players are in.

> ngrok's free plan shows a one-time "Visit Site" page on each device's first visit. Tap through it.

## Accounts

- Only **admins** (hosts) and **super admins** have accounts. Players never sign up.
- A super admin adds a host under **Users → Add user** with just an email. No email gets sent. Instead they get a **one-time setup link** to pass along. It expires in 7 days and can be regenerated.
- Opening the link lets the new host pick a name and a password (typed twice).

## Game settings

| Setting | Options |
|---|---|
| Most players | 3–20 |
| Imposters per round | A min–max range, picked at random each round. At most 1 per 3 players, never more than 6 |
| Rounds | 1–15 |
| Trips around the table per round | 2, 3, 5 or 7 |
| Category | One of the categories, or Random (a new one each round) |
| Word difficulty | Any mix of Easy, Medium and Hard |
| Votes | Open (shows who voted for whom) or Anonymous |
| When someone is voted out | Reveal their role, or keep it secret |
| Discussion | Timed (30s, 1m, 2m, 3m or 5m, then voting opens automatically) or Manual |

The full rules are on the in-app **Rules** page.

## Development

```sh
bin/dev          # Rails and the Webpack watcher, on http://localhost:3000
bundle exec rspec
```

- **Tests** are written test-first: RSpec system specs for flows, plus model and service specs for the game rules (`spec/services`). JS specs (`:js`) run headless Chromium through Playwright.
- **Plans:** `docs/plans/` holds the BRAVE breakdown and spec plan.
- **Design:** `DESIGN.md` describes the visual system ("Passed Notes"). CSS is BEM on top of the Optics design system, in `app/assets/stylesheets`.
- **Words:** `config/words.json` has about 2,400 entries in 10 broad categories, each shaped `{ word, category, lang, imposter_hint, difficulty }`. Hints are a loose nudge ("RV → vehicle"), and `difficulty` runs 0 (easy) to 2 (hard). The host picks which difficulties a game uses.
- **Avatars:** `app/assets/images/avatars/*.png`. See `AVATARS.md` there for names. Placeholders come from `node script/draw_placeholder_avatars.mjs`; drop in your own PNGs with the same names.

### How it fits together

| Model | What it is |
|---|---|
| `User` | A host account (Devise + devise_invitable), `role` of `admin` or `super_admin` |
| `Game` | A party session: join code, settings, status |
| `Player` | Someone in a game. Their phone is remembered by a signed cookie token. `backup` phones look after `handled_players` |
| `Round` | One word and one set of imposters. Status goes revealing → discussing → voting → reviewing → finished |
| `Seat` | A player's role and status (`playing`, `voted_out`, `removed`) in one round |
| `Ballot` | One vote in one trip. No target means Skip |

Game rules live in plain Ruby services:

- `RoundDealer` deals roles and the word.
- `VoteTally` counts votes, handling Skip and ties.
- `RoundReferee` decides winners and awards points.
- `PlayerRemoval` removes players.

Every state change broadcasts a Turbo 8 page refresh (over Action Cable on Postgres). Each screen re-fetches its own page, so secret words never travel to the wrong phone.
