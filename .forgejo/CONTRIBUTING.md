# Contributing

Thanks for helping. This says how the project is built and what a change is expected to carry.

## Getting set up

[mise](https://mise.jdx.dev) manages the tools and the tasks. Run `mise tasks` to see them all.

```sh
mise run setup       # Install tools and dependencies
mise run test        # Run the test suite, with the RBS signatures checked as it goes
mise run lint        # Lint every file
mise run format      # Fix what can be fixed
```

Run the work through a task rather than calling `bundle`, `rubocop` or `rspec` yourself. The tasks carry the flags
and config paths the project depends on: a bare `rubocop` reads no config, and a bare `rspec` runs with no spec
helper. If no task covers what you need, say so and suggest one.

## Tests

The suite boots a real Hanami app under `spec/fixtures/test_app` and drives it through Rack, so a change to the
slice extension shows up as a real request. Some specs run in a subprocess under a second bundle, to cover the case
where hanami-view is not installed. Both paths matter: a view must read the same either way.

## Signatures

Every public and private method carries an RBS signature. New API arrives with one.

Signatures are not written by hand. They are `#:` annotations in the code, and `mise run generate:signatures`
turns them into the RBS under `sig`. Run it after any change to `lib` and commit what it writes.

```ruby
# The slice this view belongs to, or nil when it is defined outside a slice namespace.
#
# @api public
# @since 0.2.0
#: () -> singleton(::Hanami::Slice)?
def slice
  nil
end
```

Attributes and constants take a trailing annotation instead:

```ruby
attr_reader :slice #: singleton(::Hanami::Slice)

KEYWORD_TYPES = %i[key keyreq].freeze #: Array[Symbol]
```

`sig/external` holds hand-written signatures for the constants other gems give us. Hanami and Phlex ship no RBS,
so this declares the shape we depend on and nothing more. Add to it when a signature needs to name something new.

### Two rules that will bite you

**A wrapped annotation needs the right indent.** Continuation lines start with `#` and spaces, never a second `#:`,
and the first character has to sit further right than the annotation marker:

```ruby
#: (
#    ?routes: ::Hanami::Slice::RoutesHelper?,
#    **untyped
#  ) -> void
def initialize(routes: nil, **)
```

**Getting it wrong is silent.** rbs-inline does not report a malformed annotation. It writes `untyped` instead,
and both RuboCop and `rbs validate` stay green, so a signature can quietly stop describing anything. After a
change, read what landed in `sig`.

`mise run lint` validates that the signatures parse and resolve, which is not the same as checking them. Change a
return type to something wrong and `lint:rbs` still passes.

`mise run test` is what catches it. The suite runs under RBS's runtime checker, so every call into the gem is
checked against its signature as the specs exercise it, and a wrong signature fails the suite.

## Commits

One change per commit. The subject names the code that landed, not what it does for a user, because that is what
people search the log for.

```text
lib: add the phlex view and layout base classes
```

The scope names the part of the project: `lib`, `sig`, `spec`, `scripts`, `config`, `ci`, `docs`. The body is
prose, and it says why any decision that is not obvious went the way it did.
