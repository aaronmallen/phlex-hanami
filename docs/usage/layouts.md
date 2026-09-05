# Layouts

A layout is a Phlex class that yields the view's body.

## The slice convention

Name a layout `Views::Layout` in the slice's namespace and every view in that slice renders inside it:

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

`Phlex::Hanami::Layout` is a Phlex class with `Renderable` included, so a layout reads the [view
context](view-context.md) the same way a view does. Include `Phlex::Hanami::Renderable` into your own base class
instead if you have one.

A slice with no `Views::Layout` renders its views bare. Each slice resolves its own, so the `Admin` slice uses
`Admin::Views::Layout` and falls back to nothing rather than to the app's.

## Choosing a different one

`layout` sets the layout for a class and everything under it:

```ruby
class Boxed < MyApp::View
  layout MyApp::Views::BoxLayout
end
```

Set it on a base view to cover a whole group:

```ruby
module MyApp
  class AdminView < MyApp::View
    layout MyApp::Views::AdminLayout
  end
end
```

## Opting out

`layout nil` renders the view on its own. Use it for a turbo frame, a partial response or an inline fragment:

```ruby
class Frame < MyApp::View
  layout nil
end
```

Setting is inherited, so `layout nil` on a base view opts out every view under it.

## Order, and content_for

The view's body renders first, then the layout wraps it. That order is what lets a view fill in part of the layout
it sits inside:

```ruby
class Show < MyApp::View
  def view_template
    content_for(:page_title, @post.title)
    h1 { @post.title }
  end
end
```

By the time the layout renders its `head`, `content_for(:page_title)` has the title.

## Where layouts do not apply

Only the view Hanami calls gets wrapped. A component you render with `render` never picks up a layout, so nothing
nests a page inside a page.

A layout is never wrapped in a layout either. `Phlex::Hanami::Layout` sets `layout nil` on itself, so a layout you
render directly comes out on its own.
