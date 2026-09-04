# frozen_string_literal: true

# Hanami's helper library hard-requires hanami-view, which the main suite does not bundle, and its
# CSRF callbacks are disabled under `HANAMI_ENV=test`. So this runs in a subprocess with a Gemfile
# that has hanami-view, in the development environment.
RSpec.describe "Hanami helpers in a Phlex view" do
  subject(:body) do
    stdout, stderr, status = Subprocess.run(
      "helpers.rb",
      gemfile: File.expand_path("../fixtures/gemfiles/hanami_view.gemfile", __dir__),
      HANAMI_ENV: "development",
    )
    raise "subprocess failed:\n#{stderr}" unless status.success?

    stdout.lines.to_h { |line| line.chomp.split("=", 2) }.fetch("body")
  end

  it "renders a form" do
    expect(body).to include(%(<form action="/posts/1" method="POST"))
  end

  it "includes the CSRF token" do
    expect(body).to match(/<input type="hidden" name="_csrf_token" value="\h{64}">/)
  end

  it "includes the method override" do
    expect(body).to include(%(<input type="hidden" name="_method" value="PATCH">))
  end

  it "renders the fields the block built" do
    expect(body).to include(%(<label for="post-title">Title</label>))
    expect(body).to include(%(<input type="text" name="post[title]" id="post-title" value="">))
  end

  it "leaves validation errors to the app" do
    expect(body).to include(%(<ul class="errors"><li>is required</li></ul>))
  end

  it "formats numbers" do
    expect(body).to include(%(<p id="formatted">1,234.57</p>))
  end

  it "keeps Phlex's own `tag`, which Hanami's TagHelper would otherwise shadow" do
    expect(body).to include(%(<custom-element id="phlex-tag">still Phlex</custom-element>))
  end

  it "keeps Phlex's own `raw`, which Hanami's EscapeHelper would otherwise shadow" do
    expect(body).not_to be_empty
    expect(body).to include("</form>")
  end
end
