# Phlex::Hanami

A Ruby gem that gives Hanami an object oriented view layer. Views, layouts and components are Phlex classes rather
than templates. The gem lives in `lib/phlex/hanami`, the type signatures in `sig`, and the specs drive a real
bootable Hanami app under `spec/fixtures/test_app`.

## Start Here

Read @README.md before you touch anything. It says what the gem does, what the public API looks like, and what is
on the roadmap. @docs/usage/how-it-works.md states each design decision and why Hanami is never taught that Phlex
exists. It answers most questions about why a thing has the shape it has.

@CHANGELOG.md tracks releases. The 0.1.0 on RubyGems came from the previous owner and shares no code with this
repository; releases from 0.2.0 on come from here.

## Tooling

- Ruby 4 for development. The gem supports Ruby 3.3 and up, so RuboCop targets 3.3.
- Hanami 3 and Phlex 2. hanami-view is optional, which is why `Phlex::Hanami::Helpers` is opt in.
- RSpec for tests, RBS for signatures, RuboCop for style.
- [mise] manages tools and tasks (@.config/mise.toml). Run `mise tasks` to see them.
- The repository uses [jj]. Git still works, but `jj` is the tool of record.

Always run the work through a mise task rather than calling `bundle`, `rubocop`, `rspec` or **any** other tool
yourself. The tasks in `scripts/` carry the flags and config paths this project depends on, and they are what I run,
so a bare `rubocop` reads no config at all and `rspec` runs with no spec helper.

If no existing task covers what you need, say so and suggest a new script rather than working around it with a one
off command.

`mise run setup` installs the tools and the gems. `mise run test` runs the suite, `mise run lint` runs every linter,
`mise run format` fixes what it can, and `mise run console` opens irb with the gem loaded.

## Specs

The suite boots the fixture app and drives it through Rack, so a change to the slice extension shows up as a real
request. Read @spec/support/fixture_app.rb before you add a spec that needs the app.

Some specs run in a subprocess under a second bundle (@spec/fixtures/gemfiles/hanami_view.gemfile) to cover the case
where hanami-view is not installed. Both paths matter: a view must read the same whether or not that gem is there.

## Writing Rules

Review every prose output (READMEs, changelogs, docs, commit messages) against these rules before delivering:

1. Never use a metaphor, simile or other figure of speech which you are used to seeing in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, always cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word or a jargon word if you can think of an everyday English equivalent.
6. Never use emdash
7. Break any of these rules sooner than say anything outright barbarous.

[jj]: https://jj-vcs.github.io/jj
[mise]: https://mise.jdx.dev
