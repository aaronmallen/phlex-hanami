# Mailers

A mailer pairs with a view the same way an action does. Write the view as a `Phlex::Hanami::Mailer::View` under
the slice's `Views::Mailers` namespace and the mailer renders it.

## A message

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
```

```ruby
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

`MyApp::Mailers::Welcome` looks up `views.mailers.welcome`, so the names line up the way action and view names do.
A mailer with no Phlex view falls through to whatever hanami-mailer would have done, which lets an app move its
mail across one message at a time.

Include `Phlex::Hanami::Mailer::Renderable` into your own base class if you have one, rather than subclassing.

## Layouts

Mail has its own layout convention. Name one `Views::Mailers::Layout` and every mail view in the slice renders
inside it. The web `Views::Layout` is never used for mail, because it carries the stylesheets, scripts and page
chrome no mail client wants.

```ruby
# app/views/mailers/layout.rb
module MyApp
  module Views
    module Mailers
      class Layout < Phlex::Hanami::Mailer::Layout
        def view_template
          html do
            body do
              yield
              p { "Sent by MyApp" }
            end
          end
        end
      end
    end
  end
end
```

`layout SomeOtherLayout` and `layout nil` work as they do elsewhere. See [Layouts](layouts.md).

## The plain text part

The text part comes from the same view. `Phlex::Hanami::Mailer::Text` converts the rendered HTML, layout included,
so a footer written once appears in both parts. Anchors become `label <url>`, list items become `- item`, `br`
and block elements become line breaks, and escaped entities go back to the characters they stand for.

This is a converter for markup Phlex has just produced, not a general HTML parser. Markup from somewhere else,
pasted in with `raw`, may not come out well.

Write the text part by hand by overriding `text_body`. It receives the rendered HTML, and the view's own state is
there to read:

```ruby
def text_body(_html)
  "Welcome, #{@user.name}. Read the latest: #{url(:posts)}"
end
```

## No request behind a mail view

Nobody reads an email inside the app, so `path` raises `Phlex::Hanami::RelativePathError`. Use `url`.

There is no request either, so `request`, `session`, `flash` and `csrf_token` raise and say why rather than
handing back something empty. Routes, assets, translations and `content_for` all work. A component shared between
a page and an email can ask `request?` before it reaches for any of them.

## Pairing the wrong view

An ordinary view renders one part, and a mailer asks for two. Pairing a mailer with a plain `Phlex::Hanami::View`
raises `Phlex::Hanami::MailerViewError` rather than sending a message whose text part is markup. Subclass
`Phlex::Hanami::Mailer::View`, or include `Phlex::Hanami::Mailer::Renderable`.
