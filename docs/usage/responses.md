# Responses

Hanami decides the response format, not phlex-hanami. A Phlex view renders through the same
`Hanami::Action::Response#render` a `Hanami::View` does, so the content type, the `HEAD` handling and the opt out
are all Hanami's, unchanged.

## Content type

The response content type comes from the request's `Accept` header, or from the action's configured formats when
the request sends no `Accept`. Rendering a Phlex view does not change it:

```ruby
# Accept: text/html    ->  Content-Type: text/html; charset=utf-8
# no Accept header     ->  Content-Type: application/octet-stream; charset=utf-8
get "/posts"
```

An action that sets `response.body` itself gets the same content type for the same request. Nothing needs setting
in the view, and you should not set `response.format = :html` to make a Phlex view work.

To pin an action to one format, use Hanami's own setting:

```ruby
class Index < MyApp::Action
  config.formats.accept :html
end
```

## Format is not part of the pairing

Hanami renders the paired view whenever the response body is still empty. It does not check the format first, so a
JSON action that happens to share a name with a view renders that view's HTML into the JSON body:

```ruby
# app/actions/posts/feed.rb
class Feed < MyApp::Action
  config.formats.accept :json

  def handle(_request, response)
    response[:title] = "Posts"          # no response.body =
  end
end

# app/views/posts/feed.rb -> rendered, and the response is Content-Type: application/json
```

This is Hanami's rule for any view, hanami-view included. Two ways out, both Hanami's:

- Set the body in the action. `response.body = posts.to_json` leaves nothing for Hanami to render.
- Opt the action out, below.

Restricting the format helps at the edges but does not fix this. `config.formats.accept :json` makes a request for
`text/html` halt with 406 before anything renders, but a request that asks for JSON still gets the view.

## HEAD requests

Hanami empties the body of a `HEAD` response after the action runs, so a `HEAD` returns the status and headers of
the matching `GET` with no body. The view still runs to build the body Hanami then drops. That is what Hanami does
for a `Hanami::View` too. Override `auto_render?` on an action where the render is expensive enough to matter.

## Opting an action out

Override `auto_render?`. It is Hanami's hook, documented for this, and it takes the response:

```ruby
class Show < MyApp::Action
  private

  def auto_render?(_response) = false
end
```

The paired view stays where it is and still renders when you call it, so this is how an action serves something
else while keeping its view for a different caller.

Return a condition to opt out for some requests only:

```ruby
def auto_render?(response) = super && response.format != :json
```

Put it on a base action to opt out a whole slice.
