# Yint Translation Log

This log records implementation decisions, successes, mistakes, and environment
findings while reviving Yint as a current Hoon port of MangledMUD.

## 2026-05-22: Startup

- Decision: revive the existing `yint` repository instead of starting a fresh
  desk. The existing code already contains a mechanical Hoon translation for
  records, database import/export, matching, movement, creation, look/set/speech
  slices, and a `%sole` app shell.
- Decision: use MangledMUD's Ruby test suite and command regression fixtures as
  the behavioral oracle. Ruby parity is the target; old Hoon implementation
  details are secondary when they conflict with current Urbit compatibility.
- Decision: keep changes traceable to the Ruby modules and avoid broad
  idiomatic rewrites. This should make mistakes easier to identify against the
  original source.
- Environment finding: the local `yint` remote is
  `https://github.com/hassundotx/yint`, not the older upstream shown in the
  original project history.
- Environment finding: the local Urbit base under `../mycomet/base` is on
  `%zuse 409`, while Yint declares `/? 314` and was written against a much
  older app/runtime surface. Compatibility work is expected.
- Mistake/friction: branch creation first failed in the sandbox with a
  read-only Git refs error. Retrying with explicit Git escalation succeeded.
- Decision: add `desk.bill` and `sys.kelvin` directly to this repository. The
  old README told users to copy `app/`, `gen/`, `lib/`, and `sur/` onto a fresh
  desk, but current development needs a buildable desk artifact that can be
  inserted into Clay and tested.
- Decision: target `%zuse 409`/`408`, matching the local `../mycomet/mcp` desk.
  This is a compatibility baseline, not a claim that all old app code already
  works on that Kelvin.
- Environment finding: committing the mounted `%yint` desk failed because
  `/data/phrases/json` needs `/mar/json/hoon`. I copied the local `%mcp`
  JSON mark into this repo instead of removing the phrase data, because phrase
  loading is part of the parity target.
- Environment finding: the next Clay validation failure was `/mar/txt/hoon` for
  `/data/caves/txt`. I copied the current local `%base` text mark into the repo
  for the same reason: the bundled world data should remain part of the desk.
- Environment finding: Yint's public types import `/- sole`, and the app imports
  `/+ sole`. A fresh desk did not contain Sole, so I vendored `sur/sole.hoon`,
  `lib/sole.hoon`, and the Sole action/effect marks from local `%base`. This is
  a dependency preservation step, not an app rewrite.
- Mistake/friction: I first copied both `sur/sole.hoon` and `lib/sole.hoon` to
  the mounted desk's `sur/` directory. `cp` refused to overwrite the just-created
  file, and I recopied each file to the correct location.
- Decision: modernize `sur/yint.hoon` by pinning the imported Sole core with
  `=, sole` and using unqualified `sole-effect`. A temporary Clay probe showed
  that the older `sole-effect:sole` style no longer built in this context.
- Decision: update public structure molds from old face syntax like
  `name/tape` to current syntax like `name=tape`, and mark molds with `+$`.
  A temporary probe showed that the old slash form was the remaining
  `/sur/yint.hoon` build blocker.
- Decision: update `match-types` from the old `$? $tag ... ==` form to the
  current term-union form `?(%tag ...)`. A probe showed that constants and
  signed atoms built, but the old union syntax did not.
- Decision: remove the old `!:` rune from `sur/yint.hoon`. A probe containing
  the same public molds built without it; keeping the rune in this file kept the
  Clay build failing on the current stack.
- Mistake/friction: I first formatted the modern `match-types` term union across
  multiple lines. A probe showed that this still failed under the current parser,
  while the same union on one line built.
- Decision: apply a mechanical conversion across Yint-owned Hoon files from old
  face/type syntax (`name/type`) to current syntax (`name=type`). This is broad
  but intentionally shallow; vendored `%base`/Sole files were left untouched.
- Mistake/friction: that mechanical conversion touched path-like code in
  `app/yint.hoon`, changing `/home/.../yint/...` into invalid face syntax. I
  caught it in diff review and restored the path expression before app testing.
- Decision: remove remaining old `!:` runes from Yint-owned Hoon files after the
  public type file showed that rune could block current parsing.
- Mistake/friction: I botched one mounted-desk sync by copying all converted
  Hoon files into `/app`. I removed only those wrongly copied mounted files and
  recopied each source group to its proper Clay path.
- Decision: convert old tuple braces used in gate samples, return molds, `$-`
  samples, and pattern tags to current square-bracket syntax. I intentionally
  did not rewrite braces inside interpolated strings.
- Decision: after tuple conversion, change old `$tag` variants in app card and
  Sole-action patterns to current `%tag` terms. Leaving `$tag` would preserve the
  old syntax error under a different delimiter.
- Verification: the mounted `%yint` desk now commits cleanly, and these files
  build on the local `%zuse 409` stack: `/sur/yint/hoon`, `/sur/sole/hoon`,
  `/lib/sole/hoon`, `/mar/json/hoon`, and `/mar/txt/hoon`.
- Remaining blocker: Yint-owned libraries and generators still fail through the
  MCP build wrapper (`/lib/yint/db/hoon`, `/lib/yint/util/hoon`,
  `/lib/yint/all/hoon`, `/gen/yint/import/hoon`, `/app/yint/hoon`). The wrapper
  reports only `build-failed`, so further work needs either more probes or a
  better compiler trace path.
- Environment blocker: MangledMUD's Ruby oracle could not run because this
  machine has no `ruby`, `gem`, `bundle`, or `rake` executables.

## 2026-05-22: Continue Syntax Modernization

- Decision: change `app/yint.hoon` from `/? 314` to `/? 310`, matching the
  local `%base` generator and Sole files that build on this ship.
- Decision: remove remaining `sole-effect:sole` annotations in the app after
  `sole` is already pinned into the subject.
- Decision: update generator argument samples from the old `[arg=path $~]` form
  to the current nested sample shape used by local `%base` generators,
  `[[arg=path ~] ~]`.
- Finding: `util.hoon` failed on old nested updates like `a(syslog ...)` against
  `all:yint`. Rebuilding the `io` half explicitly and returning `[world.a new-io]`
  builds on the current stack, so queue/log/logout updates now use that shape.
- Tradeoff: the old `tokenize` splitting implementation still failed around its
  `find`/`trim` recursion. I temporarily replaced it with a buildable one-line
  implementation (`~[t]`) to unblock dependent modules. This loses newline
  splitting and should be restored with tests once the core desk builds.
- Finding: `speech.hoon` sends tape messages through `queue-notification`, while
  `queue-notification` was typed as `styx`. I changed notifications to queue
  `%txt` effects from tape, matching the only current call site.
- Finding: `speech.hoon` imported `yint-all`, while `all.hoon` imports
  `yint-speech`. That cycle kept both from building. Removing the unused
  `yint-all` import from `speech.hoon` allowed both `/lib/yint/speech/hoon` and
  `/lib/yint/all/hoon` to build.
- Verification: after this pass, these Yint-owned files build:
  `/gen/yint/import/hoon`, `/gen/yint/export/hoon`,
  `/gen/yint/load-phrases/hoon`, `/lib/yint/db/hoon`,
  `/lib/yint/util/hoon`, `/lib/yint/speech/hoon`, and
  `/lib/yint/all/hoon`.
- Finding: `/lib/yint/db/hoon` first failed in the `can-link-to` predicate
  because `gte:si` and `lth:si` no longer resolve under the current stack.
  The existing source already suspected this. Replacing them with unqualified
  `gte` and `lth` made the probe build.
- Finding: the `can-link` predicate failed when reading `location:(got what)`.
  A probe showed direct `records.db` lookup builds, so the arm now binds
  `what-record` with `(~(got by records.db) what)` and reads `location.what-record`.

## 2026-05-23: Finish Library Build Revival

- Decision: remove unused matcher/database imports from `help.hoon`. The help
  screen only queues text; importing the still-failing matcher made help fail
  for no behavioral reason.
- Finding: the old flat `all:yint` accesses were the main blocker in
  `match.hoon`, `look.hoon`, `create.hoon`, `move.hoon`, and `set.hoon`.
  Reads now use `db.world.a`, `player.io.a`, and `rng.io.a`; DB mutations use a
  local `new-db` and then rebuild `[world.a(db new-db) io.a]`.
- Mistake/friction: I first tried `=^ ... new-db ...` without seeding `new-db`.
  `=^` updates an existing wing, so the build only worked after adding
  `=/ new-db=database:yint ...` before the mutation.
- Finding: `q:(trim 1 match-name.m)` failed in the matcher after the code had
  already proved `match-name.m` was non-empty. Replacing it with the direct
  tail `t.match-name.m` preserved behavior and built. The same pattern was used
  for antilock key parsing in `set.hoon`.
- Finding: `move.hoon` had undeclared dependencies on `yint-db`, `yint-look`,
  `yint-match`, and `yint-speech`. Adding the explicit imports fixed the final
  movement-library blocker.
- Decision/tradeoff: the old Gall app shell used obsolete arms and custom cards.
  A minimal probe showed that shape fails independently of the command code. I
  replaced it with a modern `default-agent` scaffold that builds and explicitly
  defers Sole/import/export runtime wiring. The command libraries remain the
  translated core; the app protocol still needs a deliberate modern Gall port.
- Mistake/friction: putting `/+ default-agent` before `/- yint` made even the
  reduced app scaffold fail. Reordering to import `yint` first fixed the build.
- Mistake/friction: I tried to sync this Markdown log into the mounted desk, but
  `%yint` has no `%md` mark. Clay rejected `/docs/translation-log/md`, so the
  log stays as Git-only documentation for now.
- Verification: all Yint-owned generators, libraries, surfaces, and the modern
  app scaffold now build on the mounted `%yint` desk.
