# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.2.0-alpha.3] - 2026-09-06

### Added

- `Phlex::Hanami::Component`, the base class for everything below a view. It reads the same view context a view
  does, and has neither a layout nor the `call` contract Hanami renders a view through, so Hanami cannot render one
  by accident.
- `Phlex::Hanami::Contextual`, the view context and the slice on their own, for a component base class you already
  have. `Phlex::Hanami::Renderable` includes it and adds the view half.
- Support for [Phlex kits]. Extend a component namespace with `Phlex::Kit`, include it in a base view, and a view
  calls its components as methods. A kit registers in the slice container as the module, so `slice["components"]`
  returns the kit rather than raising `NoMethodError`.
- `Phlex::Hanami::Testing::ViewHelpers`, for testing a view or a component without a request. `render` renders the
  instance you give it, `view_context` builds the context an action would have, and `view_request` fakes a request
  for the session, the flash and the CSRF token.
- `require "phlex/hanami/rspec"` includes those helpers into every RSpec example group tagged `type: :view`. Under
  any other framework, require `phlex/hanami/testing` and include the module where your view tests run.
- RBS signatures for the public API, shipped in `sig`.
- Documentation for [components](docs/usage/components.md), [testing](docs/usage/testing.md) and
  [responses](docs/usage/responses.md).

[Phlex kits]: https://www.phlex.fun/components/kits.html

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

[Unreleased]: https://github.com/aaronmallen/phlex-hanami/compare/0.2.0-alpha.3...HEAD
[v0.2.0-alpha.3]: https://github.com/aaronmallen/phlex-hanami/compare/0.2.0-alpha.2...0.2.0-alpha.3
[v0.2.0-alpha.2]: https://github.com/aaronmallen/phlex-hanami/compare/0.2.0-alpha.1...0.2.0-alpha.2
[v0.2.0-alpha.1]: https://github.com/aaronmallen/phlex-hanami/releases/tag/0.2.0-alpha.1
[v0.1.0]: https://github.com/stephannv/phlex-hanami/releases/tag/v0.1.0
