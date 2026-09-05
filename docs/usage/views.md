# Views

A view is a Phlex class. Hanami finds it by name, hands it the action's exposures, and renders it.

## Base classes

Subclass `Phlex::Hanami::View` for an app level base view, and write every view in the slice against that:

```ruby
# app/view.rb
module MyApp
  class View < Phlex::Hanami::View
  end
end
```

If you already have a `Phlex::HTML` base class, include `Phlex::Hanami::Renderable` into it instead. The two are
the same thing:

```ruby
module MyApp
  class View < Phlex::HTML
    include Phlex::Hanami::Renderable
  end
end
```

`Renderable` gives the class three things: the `call` contract Hanami expects, per slice configuration, and the
[view context](view-context.md).

## How Hanami finds the view

Hanami looks up a view by container key. Drop the slice's own segment from the action's name, swap `actions` for
`views`, and you have the key:

| Action                         | Key                 | View                         |
|--------------------------------|---------------------|------------------------------|
| `MyApp::Actions::Posts::Index` | `views.posts.index` | `MyApp::Views::Posts::Index` |
| `MyApp::Actions::Home`         | `views.home`        | `MyApp::Views::Home`         |
| `Admin::Actions::Posts::Show`  | `views.posts.show`  | `Admin::Views::Posts::Show`  |

Each slice keeps its own views. `Admin::Actions::Posts::Index` renders `Admin::Views::Posts::Index`, never the
app's.

Hanami's own naming rules still apply. A `create` action falls back to the `new` view and an `update` action to
`edit`, so a failed form renders the form again with the errors you exposed.

Hanami renders the view when the response body is still empty. An action that sets `response.body` itself, or
redirects, renders nothing. An action with no matching view renders nothing either, which is how a slice moves to
Phlex one action at a time.

## What a view receives

Hanami passes every response exposure merged over every request param. The view keeps the keywords its
`initialize` declares and drops the rest, so a stray query string param does not raise:

```ruby
# app/actions/posts/show.rb
def handle(request, response)
  response[:post] = posts_repo.find(request.params[:id])
end

# app/views/posts/show.rb
class Show < MyApp::View
  # `post` comes from the exposure. `id` is a param, and this view never sees it.
  def initialize(post:) = @post = post
end
```

Exposures win over params, which is Hanami's own order. A view with no initializer takes nothing:

```ruby
class About < MyApp::View
  def view_template = h1 { "About" }
end
```

A view whose initializer takes `**` opts out of the filtering and receives all of it, request params included:

```ruby
class Search < MyApp::View
  def initialize(**input) = @input = input
end
```

## Components

Everything below a view is ordinary Phlex. Write components as plain Phlex classes and render them with `render`:

```ruby
class Index < MyApp::View
  def view_template
    render Nav.new(current: :posts)
    @posts.each { |post| render PostCard.new(post:) }
  end
end
```

Components share the view context, however deep they sit, so a component nested five levels down can still call
`path` or `content_for`. See [View context](view-context.md).

Subclass your base view for a component that needs the context. Layouts wrap the view Hanami calls and nothing
else, so a component you render yourself never picks one up.

> [!NOTE]
> A component base class and `Phlex::Kit` conventions are still to come. For now, components are whatever your
> base view is.

## Rendering a view yourself

`call` takes the context as a keyword, alongside the view's own input:

```ruby
MyApp::Views::Posts::Index.call(context: MyApp::Views::Context.new, posts: posts)
```

A view that reaches for the context without one raises `Phlex::Hanami::MissingContextError`. A view that touches
neither routes, assets nor the request needs no context at all.

Note that the container hands back the class, not an instance, so `slice["views.posts.index"]` is
`MyApp::Views::Posts::Index` itself. [How it works](how-it-works.md) says why.
