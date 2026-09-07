# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Phlex::Hanami::Component`, the base class for everything below a view. It reads the same view context a view
  does, and has neither a layout nor the `call` contract Hanami renders a view through.
- `Phlex::Hanami::Contextual`, the view context and slice on their own, for an existing component base class.
  `Phlex::Hanami::Renderable` now includes it and adds the view half.
- Support for [Phlex kits](https://www.phlex.fun/components/kits.html). A module extended with `Phlex::Kit`
  registers in the slice container as the module, so `slice["components"]` returns the kit instead of raising
  `NoMethodError`.
- [Components](docs/usage/components.md) documentation, covering the base class, kits, where components live,
  sharing them between slices, and props.

## [v0.2.0-alpha.2] - 2026-09-05

### Added

- Phlex views for [hanami-mailer]. A mailer renders the Phlex class whose container key matches its own, so
  `MyApp::Mailers::Welcome` renders `MyApp::Views::Mailers::Welcome` with no configuration.
- `Phlex::Hanami::Mailer::View` and `Phlex::Hanami::Mailer::Layout`, and `Phlex::Hanami::Mailer::Renderable` for an
  existing `Phlex::HTML` base class.
- A plain text alternative part, converted from the rendered HTML by `Phlex::Hanami::Mailer::Text`. Override
  `text_body` on the view to write it by hand.
- A mail layout convention: `Views::Mailers::Layout` in a slice wraps that slice's mail views.
- Usage documentation under [docs/usage](docs/usage/README.md), covering views, layouts, the view context,
  helpers, mailers and how the gem hooks into Hanami.
- `Phlex::Hanami::MailerViewError`, raised when a mailer is paired with a Phlex view that is not a mail view,
  rather than sending a message whose plain text part is markup.

### Changed

- `url` in a view returns a String. Hanami's routes helper returns a `URI`, which Phlex rejects as an attribute
  value, so `a(href: url(:posts))` raised.

### Fixed

- `path` in a mail view raises `Phlex::Hanami::RelativePathError` instead of writing a relative link an email client
  cannot follow.

[hanami-mailer]: https://github.com/hanami/mailer

## [v0.2.0-alpha.1] - 2026-09-04

Initial alpha release by the new maintainer [@aaronmallen](https://github.com/aaronmallen).

## [v0.1.0] - 2024-12-07

Initial release, by the previous maintainer [@stephannv](https://github.com/stephannv).

[Unreleased]: https://github.com/aaronmallen/phlex-hanami/compare/0.2.0-alpha.2...HEAD
[v0.2.0-alpha.2]: https://github.com/aaronmallen/phlex-hanami/compare/0.2.0-alpha.1...0.2.0-alpha.2
[v0.2.0-alpha.1]: https://github.com/aaronmallen/phlex-hanami/releases/tag/0.2.0-alpha.1
[v0.1.0]: https://github.com/stephannv/phlex-hanami/releases/tag/v0.1.0
