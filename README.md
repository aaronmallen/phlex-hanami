# Phlex::Hanami

> [!WARNING]
> This is an alpha release. Everything here works and the spec suite covers it, but the public API is not settled.
> Names and behaviour can change between alphas with no deprecation cycle. The [roadmap](#roadmap) lists what is
> left before 0.2.0.

An object oriented view layer for [Hanami](https://hanamirb.org). Write views, layouts and components as
[Phlex](https://www.phlex.fun) classes instead of templates.

## Installation

Add the gem to your Gemfile. The version constraint is required, because Bundler will not resolve a prerelease
without one:

```ruby
gem "phlex-hanami", "~> 0.2.0.pre.alpha"
```

Or, from [gem.coop](https://gem.coop):

```ruby
gem "phlex-hanami", "~> 0.2.0.pre.alpha", source: "https://gem.coop/@aaron"
```

> [!NOTE]
> [@stephannv](https://github.com/stephannv) wrote this gem and [@aaronmallen](https://github.com/aaronmallen) now
> maintains it. 0.1.0 on RubyGems is theirs and shares no code with what is here. Releases from 0.2.0 on come from
> this repository.

## Quick start

Give the app a base view:

```ruby
# app/view.rb
module MyApp
  class View < Phlex::Hanami::View
  end
end
```

Expose what the view needs from the action:

```ruby
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
```

Write the view under the `Views` namespace, with the matching name:

```ruby
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

That is the whole setup. Hanami pairs the action with the view whose name matches and renders it. You write no
`response.render` call and change no configuration.

Name a layout `Views::Layout` and every view in the slice renders inside it:

```ruby
# app/views/layout.rb
module MyApp
  module Views
    class Layout < Phlex::Hanami::Layout
      def view_template
        doctype
        html do
          head do
            title { content_for(:page_title) || "MyApp" }
            link(rel: "stylesheet", href: asset_url("app.css"))
          end
          body { yield }
        end
      end
    end
  end
end
```

## Documentation

- [Views](docs/usage/views.md): base classes, how a view is paired with an action, and what it receives
- [Layouts](docs/usage/layouts.md): the slice convention, per view overrides and opting out
- [View context](docs/usage/view-context.md): routes, assets, `content_for`, flash, session and request
- [Helpers](docs/usage/helpers.md): Hanami's helper library, escaping and translations
- [Responses](docs/usage/responses.md): content types, JSON actions, `HEAD` requests and opting out of auto render
- [Mailers](docs/usage/mailers.md): Phlex views for hanami-mailer, and the plain text part
- [Testing](docs/usage/testing.md): helpers for view and component specs, under RSpec or Minitest
- [How it works](docs/usage/how-it-works.md): what the gem installs, and why each piece is there

## Roadmap

Before 0.2.0:

- [ ] A component base class and `Phlex::Kit` conventions for everything below a view
- [x] Response format handling, and a documented way to opt out of auto render
- [x] RSpec support for testing Phlex views in application suites
- [x] RBS signatures for the public API

After 0.2.0:

- [ ] Code reloading and memoization in development
- [ ] `hanami generate` producing Phlex views instead of ERB templates

## Development

This project uses [mise](https://mise.jdx.dev) for tools and tasks. Run `mise tasks` to see them all.

```sh
mise run setup       # Install tools and dependencies
mise run test        # Run the test suite, with the RBS signatures checked as it goes
mise run format      # Format every file
mise run lint        # Lint every file
```

[CONTRIBUTING](.github/CONTRIBUTING.md) covers the rest, including how the signatures are generated.

## License

This project is licensed under the [MIT License](LICENSE)
