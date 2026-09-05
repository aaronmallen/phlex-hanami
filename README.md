# Phlex::Hanami

> [!WARNING]
> This is an alpha release. Everything described below works and is covered by the spec suite, but the public API is
> not settled — names and behaviour can change between alphas without a deprecation cycle. See the
> [roadmap](#roadmap) for what is still outstanding before 0.2.0.

An object oriented view layer for [Hanami](https://hanamirb.org). Write views, layouts, and components as
[Phlex](https://www.phlex.fun) classes instead of templates.

## Installation

Add to your Gemfile. The constraint is required — Bundler will not resolve a prerelease without one:

```ruby
gem "phlex-hanami", "~> 0.2.0.pre.alpha"
```

Or, from [gem.coop](https://gem.coop):

```ruby
gem "phlex-hanami", "~> 0.2.0.pre.alpha", source: "https://gem.coop/@aaron"
```

> [!NOTE]
> This gem was created by [@stephannv](https://github.com/stephannv) and is now maintained by
> [@aaronmallen](https://github.com/aaronmallen). 0.1.0 on RubyGems is theirs and shares no code with what is here;
> releases from 0.2.0 on come from this repository.

## Usage

Define a base view, then write views as Phlex classes under the slice's `Views` namespace. Hanami pairs an action
with the view whose container key matches, and renders it — there is no `response.render` call and no configuration
to change.

```ruby
# app/view.rb
module MyApp
  class View < Phlex::Hanami::View
  end
end

# app/actions/posts/index.rb
module MyApp
  module Actions
    module Posts
      class Index < MyApp::Action
        include Deps["posts_repo"]

        def handle(_request, response)
          response[:posts] = posts_repo.all
        end
      end
    end
  end
end

# app/views/posts/index.rb
module MyApp
  module Views
    module Posts
      class Index < MyApp::View
        def initialize(posts:) = @posts = posts

        def view_template
          h1 { "Posts" }
          ul do
            @posts.each { |post| li { a(href: path(:post, id: post.id)) { post.title } } }
          end
        end
      end
    end
  end
end
```

A layout is an ordinary Phlex class that yields the view's body. Name one `Views::Layout` and every view in that
slice renders inside it:

```ruby
# app/views/layout.rb
module MyApp
  module Views
    class Layout < Phlex::Hanami::Layout
      def view_template
        doctype
        html do
          head do
            title { hanami_context.content_for(:page_title) || "MyApp" }
            link(rel: "stylesheet", href: asset_url("app.css"))
          end
          body { yield }
        end
      end
    end
  end
end
```

Set a different layout with `layout SomeOtherLayout`, or opt out of layouts entirely with `layout nil`. Both work on
a single view or on a slice's base view.

Inside a view, `path`, `url`, `assets`, `asset_url`, `content_for`, `csrf_token`, `flash`, `session`, `request` and
`i18n` read from the request's view context, and `hanami_context` gives you the context itself. They are available in
every component in the render tree, however deeply nested.

Hanami's standard helper library — `form_for`, `format_number`, the escape and tag helpers — is opt-in per base
class, because it needs the hanami-view gem:

```ruby
module MyApp
  class View < Phlex::Hanami::View
    include Phlex::Hanami::Helpers
  end
end
```

If you already have your own `Phlex::HTML` base class, include `Phlex::Hanami::Renderable` into it instead of
subclassing `Phlex::Hanami::View`; the two are equivalent.

### Mail

A mailer is paired with a view the same way an action is. Write the view as a `Phlex::Hanami::Mailer::View` under
the slice's `Views::Mailers` namespace, and the mailer renders it:

```ruby
# app/mailers/welcome.rb
module MyApp
  module Mailers
    class Welcome < Hanami::Mailer
      from "hello@example.com"
      to { |user| user.email }
      subject "Welcome"

      expose :user
    end
  end
end

# app/views/mailers/welcome.rb
module MyApp
  module Views
    module Mailers
      class Welcome < Phlex::Hanami::Mailer::View
        def initialize(user:) = @user = user

        def view_template
          h1 { "Welcome, #{@user.name}" }
          p { a(href: url(:posts)) { "Read the latest" } }
        end
      end
    end
  end
end
```

Mail has its own layout convention: name one `Views::Mailers::Layout` and every mail view in the slice renders
inside it. The web `Views::Layout` is never used for mail. `layout` and `layout nil` work as they do elsewhere.

The plain text part of the message comes from the same view. `Phlex::Hanami::Mailer::Text` converts the rendered
HTML, layout included, so anchors become `label <url>`, list items become `- item`, and entities are unescaped. To
write the text part yourself, override `text_body`:

```ruby
def text_body(_html)
  "Welcome, #{@user.name}. Read the latest: #{url(:posts)}"
end
```

An email is read outside the app, so `path` raises in a mail view; use `url`. There is no request behind a mail
view either, so `request`, `session`, `flash` and `csrf_token` say so rather than returning something empty. Routes,
assets, i18n and `content_for` all work.

## How it works

Requiring the gem prepends `Phlex::Hanami::Extensions::Slice` onto `Hanami::Slice::ClassMethods`, and
`Phlex::Hanami::Extensions::Mailer` onto `Hanami::Mailer` when that gem is bundled. Everything else follows from
what Hanami already does. Hanami is never taught that Phlex exists; a Phlex view is simply made to satisfy the
contract Hanami already has.

**Phlex classes register in the container as classes.** When a slice is prepared, the extension installs a
`Dry::System` component-dir `instance` proc that returns `component.loader.constant(component)` for any
`Phlex::SGML` subclass, and delegates to the normal loader for everything else. Without it `Dry::System` would call
`new` on the class while resolving — which raises for any view with a real initializer, and would memoize a single
Phlex instance that can only render once. With it, `slice["views.posts.index"]` returns the class.

**Auto-render needs nothing else.** Hanami's action looks up its paired view by container key
(`MyApp::Actions::Posts::Index` → `views.posts.index`) and, when the response body is empty, calls
`view.call(context: view_context, **exposures_and_params)`. Because the container handed back the class, that call
lands on `Phlex::Hanami::Renderable::ClassMethods#call`, which is the whole integration point.

**Input is filtered to what the view accepts.** `call` receives every response exposure merged over every request
param, and keeps only the keywords the view's `initialize` declares, so an unexpected param is dropped rather than
raising. A view whose initializer takes `**` opts out and receives all of it.

**The view context travels in Phlex's user context.** `call` stores Hanami's context under a private key in the
Phlex user context, which Phlex shares with every component in a render tree. That is why a component nested any
number of levels deep can still call `path` or `content_for`. When hanami-view is bundled the context is Hanami's
own `Hanami::View::Context`; when it is not, the extension defines a `Views::Context` subclass of
`Phlex::Hanami::Context` in each slice, filling the third-party slot
`Hanami::Extensions::Action::SliceConfiguredAction#view_context_class` already looks in. Both expose the same
surface, so a view reads the same either way.

**Layouts wrap at the entry point only.** When a view has a layout, `call` renders the view's body first and then
hands it to the layout, sharing the same context. Rendering the body first is what makes a `content_for(:page_title)`
set in the view visible in the layout's `head`. Because this happens in `call`, a component rendered with `render`
is never wrapped — only the view Hanami itself calls is.

**Per-slice configuration uses Hanami's own mechanism.** Views extend `Hanami::SliceConfigurable`, the same hook
Hanami's actions, views and mailers use, so a view knows the slice it belongs to. That is how the conventional
`Views::Layout` is resolved, and how a relative i18n key (`t(".title")`) resolves against the view's container key —
`MyApp::Views::Posts::Index` looks up `posts.index.title`.

**Mail is the same trick again.** `Hanami::Mailer` renders through any object taking `call(format:, **input)`, so
`Phlex::Hanami::Extensions::Mailer` is prepended onto it to answer `view` with the Phlex class whose container key
matches — `MyApp::Mailers::Welcome` to `views.mailers.welcome` — and a mail view answers to the format. Hanami calls
once per part, and the text part is the HTML part converted. A mailer with no Phlex view falls through to whatever
hanami-mailer would have done, so an app can move its mail over one message at a time. Nothing installs unless
hanami-mailer is bundled. Hanami has no view context to hand a mailer, because there is no request to build one
from, so the view builds the slice's own context itself, with the request left out.

**Escaping stays Phlex's.** Phlex escapes by default. Hanami's helpers return `SafeString`s meant to be interpolated
into a template, so `Hanami::View::HTML::SafeString` is marked as a Phlex safe object and emitted without
double-escaping. Where Hanami's helper library defines `raw` and `tag`, which Phlex already owns, Phlex's
implementations are mixed back in over them.

## Roadmap

In the current alpha:

- [x] Phlex views registered in slice containers as classes, not instances
- [x] `Phlex::Hanami::View` and `Renderable`, with per-slice configuration
- [x] Auto-render from actions, with no `response.render` and no `view_name_inferrer` override
- [x] View context wired into the action's `view_context_class`, with and without hanami-view bundled
- [x] Layouts: a base class, a per-slice convention, a per-view override and an opt-out
- [x] Hanami's standard helpers, i18n and CSRF-protected forms inside Phlex views
- [x] A bootable Hanami app fixture the spec suite drives through real requests
- [x] Phlex views for hanami-mailer, with a generated plain text alternative part

Before 0.2.0 final:

- [ ] A component base class and `Phlex::Kit` conventions for everything below a view
- [ ] Response format handling, and a documented way to opt out of auto-render
- [ ] RSpec support for testing Phlex views in application suites
- [ ] RBS signatures for the public API
- [ ] Usage documentation beyond this README

After 0.2.0:

- [ ] Code reloading and memoization in development
- [ ] `hanami generate` producing Phlex views instead of ERB templates

## Development

This project uses [mise](https://mise.jdx.dev) for tools and tasks. Run `mise tasks` to see them all.

```sh
mise run setup    # Install tools and dependencies
mise run test     # Run the test suite
mise run format   # Format every file
mise run lint     # Lint every file
```

## License

This project is license under the [MIT License](LICENSE)
