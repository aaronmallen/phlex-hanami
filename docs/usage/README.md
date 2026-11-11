# Usage

Guides for the parts of phlex-hanami, in the order most people meet them. The
[README](../../README.md#quick-start) covers the first five minutes.

- [Views](views.md)

  The base classes, how Hanami finds the view for an action, what a view receives, and what happens to input the
  view did not ask for.

- [Layouts](layouts.md)

  The `Views::Layout` convention, setting a different layout, opting out, and where `content_for` fits.

- [Components](components.md)

  The component base class, kits, where components live, sharing them between slices, and props.

- [View context](view-context.md)

  Routes, assets, `content_for`, flash, session, request and i18n, in a view and in every component under it.

- [Helpers](helpers.md)

  Hanami's helper library, why it is opt in, how escaping works, and translations with relative keys.

- [Responses](responses.md)

  Where the content type comes from, what happens when a JSON action shares a name with a view, `HEAD` requests,
  and how an action opts out of auto rendering.

- [Mailers](mailers.md)

  Phlex views for hanami-mailer, the mail layout convention, and the plain text part of a message.

- [Testing](testing.md)

  Rendering a view or component in a test, building a context, and faking a request for the session, flash and
  CSRF cases. Wired up for RSpec, and a module to include anywhere else.

- [How it works](how-it-works.md)

  What the gem installs into Hanami and why. Read this before changing the gem, or when something surprises you.
