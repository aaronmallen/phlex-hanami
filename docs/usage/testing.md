# Testing

A view is a Ruby object, so a view test builds one and calls it. The only thing it needs that an ordinary object
does not is a view context, because `path`, `assets`, `flash` and the rest are read off the context Hanami builds
for each request. phlex-hanami ships helpers that build one for you.

The helpers are three methods in `Phlex::Hanami::Testing::ViewHelpers`, and none of them know what test framework
you use. RSpec gets a file that wires them up for you. Anything else includes the module.

## Setup with RSpec

Require it from `spec/spec_helper.rb`, or from a file under `spec/support`, which the spec helper [hanami-rspec]
generates already loads:

```ruby
# spec/support/phlex.rb
require "phlex/hanami/rspec"
```

That is the whole integration. hanami-rspec is a generator gem and adds nothing at runtime, so there is nothing to
order this against.

The helpers go into every example group tagged `type: :view`. Tag component specs the same way, since a component
is a view as far as this is concerned. To pick them up somewhere else, include them by hand:

```ruby
RSpec.configure do |config|
  config.include Phlex::Hanami::Testing::ViewHelpers
end
```

## Setup with Minitest

`hanami new --test=minitest` generates a `test/support/minitest.rb` that reopens the base test class for helpers.
Include the module there, and every test gets them:

```ruby
# test/support/minitest.rb
require "phlex/hanami/testing"

class Hanami::Minitest::Test
  include Phlex::Hanami::Testing::ViewHelpers
end
```

`render` is a common enough name that you may not want it on every test in the suite. Include it into a base class
for view tests instead:

```ruby
# test/support/view_test.rb
require "phlex/hanami/testing"

class ViewTest < Hanami::Minitest::Test
  include Phlex::Hanami::Testing::ViewHelpers
end
```

The examples below are written for RSpec. Every helper works the same under Minitest; only the assertions change.

## A view spec

```ruby
# spec/my_app/views/posts/index_spec.rb
RSpec.describe MyApp::Views::Posts::Index, type: :view do
  subject(:html) { render(described_class.new(posts: posts)) }

  let(:posts) { [Post.new(title: "First")] }

  it "lists the posts" do
    expect(html).to include("<li>First</li>")
  end

  it "links to each post" do
    expect(html).to include(%(<a href="/posts/1">))
  end
end
```

No request runs. `render` builds a context from the view's own slice, so `path` and `assets` give the same answers
they give in production, and a view in the `admin` slice gets the `admin` slice's routes.

`render` renders the instance you hand it, so no layout is applied and you are asserting on the view's own markup.
To render a view inside its layout the way Hanami does, call the class:

```ruby
described_class.call(context: view_context, posts: posts)
```

There are no matchers. The output is a String, and `include`, `match` and whatever HTML matcher you already like
all work on it.

## A component spec

The same, with a block if the component takes one:

```ruby
RSpec.describe MyApp::Components::Card, type: :view do
  it "wraps its content" do
    html = render(described_class.new(title: "Hello")) { "body" }

    expect(html).to include("<h2>Hello</h2>")
    expect(html).to include("body")
  end
end
```

A plain `Phlex::HTML` class that never heard of Hanami renders through `render` too. It has no slice, so it gets a
bare context, which answers `content_for` and raises a clear error for anything else.

## Views that need a request

`session`, `flash` and `csrf_token` come from the request. `view_request` builds one without running an action:

```ruby
RSpec.describe MyApp::Views::Layout, type: :view do
  it "shows the flash" do
    request = view_request("/posts", flash: { alert: "Not saved" })

    expect(render(described_class.new, request: request)).to include("Not saved")
  end
end
```

`view_request` takes a path, and `session:`, `flash:` and `csrf_token:` for the three things a view reads off it.
Anything else goes to `Rack::MockRequest.env_for`, so headers and a request method are available when a view cares
about them. Sessions are always on, so a view reading an empty session gets nil rather than an error.

## Building the context yourself

`view_context` returns the context `render` would have built, for the times you want to set something on it first:

```ruby
it "reads content set elsewhere" do
  context = view_context
  context.content_for(:page_title, "Posts")

  expect(render(described_class.new, context: context)).to include("<title>Posts</title>")
end
```

It takes `slice:` to build from a slice other than the app, and `request:` to attach a request. The class it builds
is the one an action would build: a `Hanami::View::Context` subclass when hanami-view is bundled, otherwise
`Phlex::Hanami::Context`. A view reads the same either way.

Hanami turns off container memoization in the test env so that components can be stubbed. Each context resolves its
routes, assets and i18n backend from the container as it is built, rather than holding a set from an earlier
example.

[hanami-rspec]: https://github.com/hanami/rspec
