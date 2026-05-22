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
