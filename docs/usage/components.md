# Components

A view is the entry point Hanami calls. A component is everything below it. Subclass
`Phlex::Hanami::Component` and render it with `render`:

```ruby
# app/components/card.rb
module MyApp
  module Components
    class Card < Phlex::Hanami::Component
      def initialize(post:) = @post = post

      def view_template
        article do
          h2 { a(href: path(:post, id: @post.id)) { @post.title } }
          yield if block_given?
        end
      end
    end
  end
end
```

```ruby
class Index < MyApp::View
  def view_template
    @posts.each { |post| render MyApp::Components::Card.new(post: post) }
  end
end
```

A component reads the same [view context](view-context.md) a view does, so `path`, `assets`, `content_for`,
`flash`, `session` and `t` all work. Phlex shares that context with every component in the tree, so one nested
five levels down still has it.

If you already have a base class of your own, include the module instead:

```ruby
module MyApp
  class Component < Phlex::HTML
    include Phlex::Hanami::Contextual
  end
end
```

`Phlex::Hanami::Renderable` is the view half: the same context, plus a layout and the `call` contract Hanami's
`Response#render` needs. `Contextual` is that context on its own.

## What a component does not have

**No layout.** A layout wraps the view Hanami calls and nothing else, so a component never picks one up and needs
no opt out. See [Layouts](layouts.md).

**No `call(context:, **input)`.** Only a view answers that. Phlex's own `.call` forwards its arguments to `new`,
which is what you want from a component and wrong for a view, so a component cannot be auto rendered by accident.

## Where components live

Under `app/components` or `slices/<slice>/components`, matching the namespace. Hanami registers them in the slice
container like anything else, so `slice["components.card"]` returns the class, the same way a view does.

There is no reason to exclude them. Registration is lazy, the key costs nothing, and having it means a component
resolves the same way every other class in the slice does. If you would rather they were not registered at all,
that is `config.no_auto_register_paths`, and it is your call rather than the gem's:

```ruby
# config/app.rb
config.no_auto_register_paths << "components"
```

## Kits

A [kit](https://www.phlex.fun/components/kits.html) turns a namespace into a set of methods. Give the module a
file and extend it:

```ruby
# app/components.rb
module MyApp
  module Components
    extend Phlex::Kit
  end
end
```

Every Phlex class in the namespace now has a method named after it. Include the kit in your base view and call
components by name:

```ruby
module MyApp
  class View < Phlex::Hanami::View
    include MyApp::Components
  end
end
```

```ruby
class Index < MyApp::View
  def view_template
    Card(post: @post) { p { "body" } }
  end
end
```

Kit components can call each other the same way, with no include. Nested modules become kits of their own, so
`MyApp::Components::Forms::Field` works once the parent is extended.

This survives Hanami's autoloading. Phlex resolves a component's constant the first time you call its method,
which is what Zeitwerk needs.

## Sharing components between slices

Put them in the app namespace and use them from anywhere:

```ruby
module Admin
  module Views
    module Posts
      class Index < Admin::View
        def view_template
          render MyApp::Components::Card.new(post: @post)
        end
      end
    end
  end
end
```

A component takes the context of whoever renders it, not its own slice's, so the card above reads the `Admin`
request's routes, assets and flash. Its own slice only decides one thing: what a relative translation key resolves
against.

## Components outside a slice

`Hanami::SliceConfigurable` finds a slice by matching the class name against each slice namespace. A component
named outside all of them, in a gem or a shared library, gets no slice. `slice` returns nil.

Everything that reads the context still works, because the context comes from the render, not the slice. What you
lose is `t(".title")`, which has nothing to resolve against and raises `I18n::ArgumentError`. Use an absolute key
there.

## Props

The gem stays out of this. A Phlex class collects its props in `initialize`, and plain keyword arguments are
enough:

```ruby
def initialize(post:, compact: false)
  @post = post
  @compact = compact
end
```

If you want types and defaults declared instead, [Literal](https://literal.fun) fits without any help from us:

```ruby
class Card < Phlex::Hanami::Component
  extend Literal::Properties

  prop :post, Post
  prop :compact, _Boolean, default: false
end
```

## Testing

The same helpers as a view. See [Testing](testing.md).

```ruby
RSpec.describe MyApp::Components::Card, type: :view do
  it "links to the post" do
    expect(render(described_class.new(post: post))).to include(%(<a href="/posts/1">))
  end
end
```
