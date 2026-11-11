# frozen_string_literal: true

# The security-relevant part of the gem: marking Hanami's SafeStrings as trusted must not make
# anything else trusted.
RSpec.describe "escaping user-supplied strings", type: :request do
  before { get "/posts/-/escaping" }

  it "escapes a string rendered as text" do
    expect(last_response.body)
      .to include(%(<p id="plain">&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</p>))
  end

  it "escapes a string interpolated into a translation" do
    expect(last_response.body).to include(%(<p id="interpolated">Hello &lt;script&gt;))
  end

  it "never emits a script tag in element content" do
    expect(last_response.body).not_to match(/>\s*<script>/)
  end

  it "does not make ordinary Strings safe" do
    dangerous = "<script>"

    expect(dangerous).not_to be_a(Phlex::SGML::SafeObject)
  end

  # Phlex escapes the quote that could break out of an attribute, but leaves `<` and `>` alone —
  # inside a quoted attribute value they are inert text, not markup. Asserting the quote is the
  # property that matters; asserting `&lt;` would just be pinning down Phlex's cosmetics.
  it "escapes the quotes that could break out of an attribute" do
    expect(last_response.body).to include(%(title="<script>alert(&quot;xss&quot;)</script>"))
  end
end
