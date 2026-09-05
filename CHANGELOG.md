# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

## [v0.2.0-alpha.1] - 2024-10-05

Initial alpha release by the new maintainer [@aaronmallen](https://github.com/aaronmallen).

## [v0.1.0] - 2024-12-07

Initial release, by the previous maintainer [@stephannv](https://github.com/stephannv).

[Unreleased]: https://github.com/aaronmallen/phlex-hanami/compare/0.1.0...HEAD
[v0.1.0]: https://github.com/stephannv/phlex-hanami/releases/tag/v0.1.0
