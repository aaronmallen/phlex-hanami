# frozen_string_literal: true

module Phlex
  module Hanami
    module Mailer
      # Turns the HTML part of a message into its plain text alternative.
      #
      # This is regex over markup Phlex has just produced, not a general HTML parser. It knows the
      # handful of things that matter in an email — anchors, lists, line breaks, block elements and
      # the entities Phlex escapes — and leaves everything else on the floor. Markup from somewhere
      # else, pasted into a view with `raw`, may not come out well.
      #
      # {Renderable#text_body} calls this. Override that method to write the text part by hand.
      #
      # @api public
      # @since 0.2.0
      class Text
        # Elements that end a line of text, and so become a blank line.
        #
        # @api private
        # @since 0.2.0
        BLOCK_ELEMENTS = %w[
          article blockquote div footer h1 h2 h3 h4 h5 h6 header hr li ol p section table td tr ul
        ].freeze #: Array[String]

        # @api private
        # @since 0.2.0
        BLOCK_PATTERN = %r{</?(?:#{BLOCK_ELEMENTS.join('|')})\b[^>]*>}i #: Regexp

        # The entities Phlex escapes, and the characters they stand for.
        #
        # @api private
        # @since 0.2.0
        ENTITIES = {
          "&#39;" => "'",
          "&amp;" => "&",
          "&apos;" => "'",
          "&gt;" => ">",
          "&lt;" => "<",
          "&nbsp;" => " ",
          "&quot;" => '"',
        }.freeze #: Hash[String, String]

        # @api private
        # @since 0.2.0
        ENTITY_PATTERN = /&(?:amp|apos|gt|lt|nbsp|quot|#39);/ #: Regexp

        # Stand in for the angle brackets around a URL until the tags are gone, so that stripping
        # tags does not eat the link the converter has just written.
        #
        # @api private
        # @since 0.2.0
        LINK_CLOSE = "\u0011" #: String

        # @api private
        # @since 0.2.0
        LINK_OPEN = "\u0010" #: String

        class << self
          # Converts rendered HTML to plain text.
          #
          # @param html [String] the rendered HTML part
          #
          # @return [String] the text part
          #
          # @api public
          # @since 0.2.0
          #: (_ToS) -> String
          def call(html)
            text = body_of(html.to_s)
            text = strip_hidden_elements(text)
            text = expand_anchors(text)
            text = expand_breaks(text)
            text = expand_list_items(text)
            text = expand_blocks(text)
            text = strip_tags(text)
            text = unescape(text)
            restore_links(tidy(text))
          end

          private

          # `Label <https://example.com/path>`, or one of the two when the other adds nothing.
          #: (String, String) -> String
          def anchor_text(attributes, inner)
            url = href_in(attributes)
            label = strip_tags(inner).gsub(/\s+/, " ").strip
            return label if url.empty?
            return url if label.empty? || label == url

            "#{label} #{LINK_OPEN}#{url}#{LINK_CLOSE}"
          end

          #: (String) -> String
          def body_of(html) = html[%r{<body\b[^>]*>(.*?)</body>}mi, 1] || html

          #: (String) -> String
          def expand_anchors(html)
            html.gsub(%r{<a\b([^>]*)>(.*?)</a>}mi) { anchor_text(Regexp.last_match(1), Regexp.last_match(2)) }
          end

          #: (String) -> String
          def expand_blocks(html) = html.gsub(BLOCK_PATTERN, "\n\n")

          #: (String) -> String
          def expand_breaks(html) = html.gsub(%r{<br\b[^>]*/?>}i, "\n")

          #: (String) -> String
          def expand_list_items(html) = html.gsub(%r{</li\s*>}i, "").gsub(/<li\b[^>]*>/i, "\n- ")

          #: (String) -> String
          def href_in(attributes)
            match = attributes.match(/\bhref\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'>]+))/i)
            return "" unless match

            (match[1] || match[2] || match[3]).to_s.strip
          end

          #: (String) -> String
          def restore_links(text) = text.gsub(LINK_OPEN, "<").gsub(LINK_CLOSE, ">")

          #: (String) -> String
          def strip_hidden_elements(html) = html.gsub(%r{<(head|style|script)\b[^>]*>.*?</\1\s*>}mi, "")

          #: (String) -> String
          def strip_tags(html) = html.gsub(/<!--.*?-->/m, "").gsub(/<[^>]*>/, "")

          #: (String) -> String
          def tidy(text) = text.gsub(/[ \t]+/, " ").gsub(/[ \t]+$/, "").gsub(/\n{3,}/, "\n\n").strip

          #: (String) -> String
          def unescape(text) = text.gsub(ENTITY_PATTERN) { ENTITIES.fetch(Regexp.last_match(0)) }
        end
      end
    end
  end
end
