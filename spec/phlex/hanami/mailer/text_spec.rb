# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Mailer::Text do
  describe ".call" do
    it "takes the body when the markup has one" do
      html = "<html><head><title>Ignored</title></head><body><p>Kept</p></body></html>"

      expect(described_class.call(html)).to eq("Kept")
    end

    it "converts markup that has no body element" do
      expect(described_class.call("<p>Kept</p>")).to eq("Kept")
    end

    it "drops style and script elements" do
      html = "<p>Kept</p><style>p { color: red }</style><script>alert(1)</script>"

      expect(described_class.call(html)).to eq("Kept")
    end

    it "writes an anchor as its label and URL" do
      html = %(<a href="https://example.com/posts">All posts</a>)

      expect(described_class.call(html)).to eq("All posts <https://example.com/posts>")
    end

    it "writes an anchor with no label as its URL" do
      expect(described_class.call(%(<a href="https://example.com"></a>))).to eq("https://example.com")
    end

    it "writes an anchor whose label is its URL only once" do
      html = %(<a href="https://example.com">https://example.com</a>)

      expect(described_class.call(html)).to eq("https://example.com")
    end

    it "writes an anchor with no href as its label" do
      expect(described_class.call("<a>All posts</a>")).to eq("All posts")
    end

    it "reads an href quoted either way, or not at all" do
      html = "<a href='https://one.example'>One</a><a href=https://two.example>Two</a>"

      expect(described_class.call(html)).to eq("One <https://one.example>Two <https://two.example>")
    end

    it "marks list items" do
      expect(described_class.call("<ul><li>One</li><li>Two</li></ul>")).to eq("- One\n- Two")
    end

    it "turns a break into a newline" do
      expect(described_class.call("One<br>Two")).to eq("One\nTwo")
    end

    it "separates block elements with a blank line" do
      expect(described_class.call("<p>One</p><p>Two</p>")).to eq("One\n\nTwo")
    end

    it "drops comments" do
      expect(described_class.call("<p>Kept<!-- dropped --></p>")).to eq("Kept")
    end

    it "unescapes the entities Phlex writes" do
      html = "<p>Tea &amp; biscuits &lt;here&gt; &quot;now&quot; &#39;then&#39;</p>"

      expect(described_class.call(html)).to eq(%(Tea & biscuits <here> "now" 'then'))
    end

    it "collapses runs of whitespace and trims the ends" do
      expect(described_class.call("<p>  One   Two  </p>\n\n\n<p>Three</p>")).to eq("One Two\n\nThree")
    end

    it "is empty for empty markup" do
      expect(described_class.call("")).to eq("")
    end

    it "accepts anything that converts to a string" do
      expect(described_class.call(nil)).to eq("")
    end
  end
end
