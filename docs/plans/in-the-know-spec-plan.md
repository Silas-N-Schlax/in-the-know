# Feature: In the Know

## Feature summary

See `docs/plans/brave-breakdown.md` for the full breakdown. This plan lists the specs that drive each slice, outside in.

## Test coverage

### Slice 0: accounts

#### `spec/system/host_sessions_spec.rb`
- [x] a host signs in from the Sign in link on the home page and lands on their games
- [x] a host signs out
- [x] the host area requires signing in

#### `spec/system/admin/users_spec.rb`
- [x] a super admin searches users by name or email
- [x] a super admin creates a user and sees a one-time setup link
- [x] a super admin changes a user's role
- [x] a super admin generates a new setup link for a pending user
- [x] a regular admin cannot reach user management

#### `spec/system/account_setup_spec.rb`
- [x] a new user opens the setup link, sets name and password (twice), and is signed in
- [x] mismatched passwords show an error
- [x] a used setup link no longer works

#### `spec/models/user_spec.rb`
- [x] requires a name once setup is finished, but not while pending
- [x] `.search` matches name or email, ignoring case

### Slice 1: lobby

#### `spec/system/host_creates_game_spec.rb`
- [x] a host creates a game with settings and sees the 4-character join code
- [x] invalid settings show clear errors (imposter range above players ÷ 3, min > max, and so on)

#### `spec/system/joining_spec.rb`
- [x] a player joins with code and name, then picks an animal
- [x] an unknown code, a blank name, a name over 16 characters, a full game, or a game already started each show a clear error
- [x] a taken animal greys out live on another phone (js)
- [x] picking an animal someone just took shows a friendly error
- [x] joining with a taken name offers to rejoin as that player, which moves them to the new phone

#### `spec/models/game_spec.rb`
- [x] generates a unique 4-character code among open games
- [x] validates settings ranges and `max_imposters_for` (players ÷ 3, capped at 6)

#### `spec/models/player_spec.rb`
- [x] names are unique per game, ignoring case and extra spaces, with at most 16 characters
- [x] an animal can be used only once per game
- [x] `.available_avatars` lists the animals not yet taken

### Slices 2 and 3: rounds and voting

#### `spec/services/round_dealer_spec.rb`
- [x] deals a random number of imposters within the range, limited by active players
- [x] never repeats a word within a game, and uses the game's category or a random one
- [x] skips players removed for the rest of the game

#### `spec/services/vote_tally_spec.rb`
- [x] the most-voted player goes out
- [x] a tie means nobody goes out
- [x] Skip winning means nobody goes out
- [x] anyone who didn't vote counts as Skip

#### `spec/services/round_referee_spec.rb`
- [x] Insiders win when every imposter is out, and every Insider gets a point
- [x] imposters win when it's down to 1 imposter and 1 Insider
- [x] imposters win when only imposters are left
- [x] imposters win if any survive the last rotation
- [x] otherwise the round continues

#### `spec/system/playing_a_round_spec.rb` (js)
- [x] the host starts the game, and phones privately reveal the word or the hint
- [x] the host opens voting, phones vote, and the result is shown on the host screen
- [x] voted-out players see the out screen
- [x] the leaderboard updates at the end of the round, and the game ends after the last round

### Slice 4: backup devices
- [x] the host makes a player a backup, and that phone adds players
- [x] the backup phone runs pass-around reveals and votes

### Slice 5: removal
- [x] the host removes a player for this round only or for the rest of the game

### Slice 7: content
- [x] How to Play and Rules pages open without signing in, from every screen
- [x] `WordBank` loads valid entries with a word, category, lang and imposter_hint
