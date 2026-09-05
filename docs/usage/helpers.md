# Helpers

## Escaping

Phlex escapes by default, and phlex-hanami keeps it that way. Text is escaped, attribute values are escaped, and
markup only appears when you ask for it with `raw`:

```ruby
p { @comment.body }        # escaped
p { raw(safe(@rendered)) } # markup, because you said so
```

Hanami's helpers return a `Hanami::View::HTML::SafeString`, which is markup Hanami has already escaped. Those
strings are marked safe for Phlex, so they render as markup rather than coming out escaped twice.

## Translations

`t` is there in every view. A relative key resolves against the view's own container key, so
`MyApp::Views::Posts::Index` looks up `posts.index`:

```ruby
class Index < MyApp::View
  def view_template
    h1 { t(".title") }      # posts.index.title
    p { t("shared.intro") } # shared.intro
  end
end
```

```yaml
# config/i18n/en.yml
en:
  posts:
    index:
      title: "Posts"
```

An anonymous view, or one outside a slice, has no container key to resolve against, so a relative key there raises
`I18n::ArgumentError`. Use an absolute key.

`i18n` gives you the slice's backend for anything `t` does not cover.

## Hanami's helper library

`form_for`, `format_number`, the asset helpers and the rest of Hanami's standard helpers are opt in per base
class, because they need the hanami-view gem and a view should not depend on what happens to be in your Gemfile:

```ruby
module MyApp
  class View < Phlex::Hanami::View
    include Phlex::Hanami::Helpers
  end
end
```

The helpers build strings to interpolate into a template. Phlex writes to a buffer instead, so pass their output
to `raw`:

```ruby
class Edit < MyApp::View
  def initialize(post:) = @post = post

  def view_template
    raw(form_for("post", path(:post, id: @post.id), values: { post: @post }, method: :patch) do |f|
      f.label("Title", for: :title) + f.text_field(:title) + f.submit("Save")
    end)

    p { format_number(@post.view_count) }
  end
end
```

`form_for` writes the CSRF token and the method override into the form for you.

Most of the library duplicates something Phlex already does better, since Phlex escapes by default and is itself a
tag builder. Reach for `form_for`, `format_number` and the asset helpers, and write the rest as ordinary Phlex.

Two of Hanami's helpers share a name with a Phlex method: `raw` and `tag`. Phlex's win. Hanami's `raw` returns a
string, so letting it through would break the one method you need in order to render a helper's output at all.
