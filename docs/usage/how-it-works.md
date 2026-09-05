# How it works

Requiring the gem prepends `Phlex::Hanami::Extensions::Slice` onto `Hanami::Slice::ClassMethods`, and
`Phlex::Hanami::Extensions::Mailer` onto `Hanami::Mailer` when that gem is bundled. Everything else follows from
what Hanami already does. Hanami is never taught that Phlex exists. A Phlex view is made to satisfy the contract
Hanami already has.

## Phlex classes register as classes

When a slice is prepared, the extension installs a `Dry::System` component dir `instance` proc. It returns
`component.loader.constant(component)` for any `Phlex::SGML` subclass and delegates to the normal loader for
everything else.

Without it, `Dry::System` would call `new` on the class while resolving. That raises for any view with a real
initializer, and it would memoize one Phlex instance, which can only render once. With it,
`slice["views.posts.index"]` returns the class.

## Auto render needs nothing else

Hanami's action looks up its paired view by container key, `MyApp::Actions::Posts::Index` to `views.posts.index`,
and calls `view.call(context: view_context, **exposures_and_params)` when the response body is empty. Because the
container handed back the class, that call lands on `Phlex::Hanami::Renderable::ClassMethods#call`. That method is
the whole of the integration.

## Input is filtered to what the view accepts

`call` receives every response exposure merged over every request param, and keeps only the keywords the view's
`initialize` declares, so an unexpected param is dropped rather than raising. A view whose initializer takes `**`
opts out and receives all of it.

## The view context travels in Phlex's user context

`call` stores Hanami's context under a private key in the Phlex user context, which Phlex shares with every
component in a render tree. That is why a component nested any number of levels deep can still call `path` or
`content_for`.

With hanami-view bundled, the context is Hanami's own `Hanami::View::Context`. Without it, the extension defines a
`Views::Context` subclass of `Phlex::Hanami::Context` in each slice, filling the third party slot
`Hanami::Extensions::Action::SliceConfiguredAction#view_context_class` already looks in. Both expose the same
surface, so a view reads the same either way.

## Layouts wrap at the entry point only

When a view has a layout, `call` renders the view's body first and then hands it to the layout, sharing the same
context. Rendering the body first is what makes a `content_for(:page_title)` set in the view visible in the
layout's `head`. Because this happens in `call`, a component rendered with `render` is never wrapped. Only the
view Hanami itself calls is.

## Per slice configuration uses Hanami's own mechanism

Views extend `Hanami::SliceConfigurable`, the same hook Hanami's actions, views and mailers use, so a view knows
the slice it belongs to. That is how the conventional `Views::Layout` is resolved, and how a relative i18n key
resolves against the view's container key: `MyApp::Views::Posts::Index` looks up `posts.index.title`.

## Mail is the same trick again

`Hanami::Mailer` renders through any object taking `call(format:, **input)`, so
`Phlex::Hanami::Extensions::Mailer` is prepended onto it to answer `view` with the Phlex class whose container key
matches, `MyApp::Mailers::Welcome` to `views.mailers.welcome`. A mail view answers to the format. Hanami calls
once per part, and the text part is the HTML part converted.

A mailer with no Phlex view falls through to whatever hanami-mailer would have done, so an app can move its mail
over one message at a time. Nothing installs unless hanami-mailer is bundled. Hanami has no view context to hand a
mailer, because there is no request to build one from, so the view builds the slice's own context itself, with the
request left out.

## Escaping stays Phlex's

Phlex escapes by default. Hanami's helpers return `SafeString`s meant to be interpolated into a template, so
`Hanami::View::HTML::SafeString` is marked as a Phlex safe object and emitted without escaping twice. Where
Hanami's helper library defines `raw` and `tag`, which Phlex already owns, Phlex's implementations are mixed back
in over them.
