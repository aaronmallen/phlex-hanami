# View context

Hanami builds one context per request and hands it to the view. phlex-hanami puts it in Phlex's user context,
which Phlex shares with every component in a render tree, so a component nested any number of levels deep reads
the same context the view does.

## What a view can call

| Method              | What it gives you                                                |
|---------------------|------------------------------------------------------------------|
| `path(...)`         | The path for a named route, as a String                          |
| `url(...)`          | The full URL for a named route, as a String                      |
| `routes`            | The slice's routes helper                                        |
| `assets`            | The slice's assets                                               |
| `asset_url(source)` | The URL for one asset                                            |
| `content_for(...)`  | Store a string of markup for later, or read back what was stored |
| `csrf_token`        | The current request's CSRF token                                 |
| `flash`             | The flash hash                                                   |
| `session`           | The session                                                      |
| `request`           | The current request                                              |
| `i18n`              | The slice's i18n backend                                         |
| `slice`             | The slice the view belongs to                                    |
| `hanami_context`    | The context itself                                               |

```ruby
class Show < MyApp::View
  def view_template
    content_for(:page_title, @post.title)

    h1 { @post.title }
    a(href: path(:edit_post, id: @post.id)) { "Edit" } if session[:user_id]
    img(src: asset_url("cover.png"))
  end
end
```

`url` hands back a String. Hanami's routes helper returns a `URI`, and Phlex rejects anything but a String as an
attribute value.

## Two questions

`hanami_context?` says whether a context is there at all, and `request?` whether a request sits behind it. Use
them in a component that has to work in both a page and an email:

```ruby
def view_template
  a(href: request? ? path(:posts) : url(:posts)) { "Posts" }
end
```

A view that reaches for the context without one raises `Phlex::Hanami::MissingContextError`. See [rendering a view
yourself](views.md#rendering-a-view-yourself).

## Forms and CSRF

`csrf_token` is the token for the current request. Write the hidden field yourself, or let Hanami's `form_for` do
it. See [Helpers](helpers.md).

```ruby
form(action: path(:posts), method: "post") do
  input(type: "hidden", name: "_csrf_token", value: csrf_token)
  input(type: "text", name: "post[title]")
  button { "Save" }
end
```

## Which context class

With the hanami-view gem bundled, the context is Hanami's own `Hanami::View::Context`, the same object the rest of
the app sees. Without it, phlex-hanami defines a `Views::Context` in each slice, a subclass of
`Phlex::Hanami::Context`, with the same public surface. A view reads the same either way.

Add your own methods by defining the class yourself before the slice boots. phlex-hanami leaves it alone if it is
already there:

```ruby
# app/views/context.rb
module MyApp
  module Views
    class Context < Phlex::Hanami::Context
      def current_user = request.env["app.current_user"]
    end
  end
end
```

With hanami-view bundled, subclass `Hanami::View::Context` instead, the way Hanami documents.

## Outside a request

A mail view has no request behind it. Routes, assets, translations and `content_for` all work; `request`,
`session`, `flash` and `csrf_token` raise and say why. See [Mailers](mailers.md).
