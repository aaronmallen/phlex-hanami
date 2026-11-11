# frozen_string_literal: true

RSpec.describe Phlex::Hanami::Props do
  let(:types) { TestApp::Types }

  def component(&)
    Class.new(Phlex::Hanami::Component) do
      include Phlex::Hanami::Props

      class_eval(&)
    end
  end

  def ivar(instance, name) = instance.instance_variable_get(:"@#{name}")

  describe "a dry type" do
    it "assigns the value to an instance variable of the same name" do
      types = self.types
      card = component { prop :title, types::String }.new(title: "Hello")

      expect(ivar(card, :title)).to eq("Hello")
    end

    it "coerces the value" do
      types = self.types
      card = component { prop :count, types::Params::Integer }.new(count: "5")

      expect(ivar(card, :count)).to eq(5)
    end

    it "raises when the type rejects the value, keeping the type's error as the cause" do
      types = self.types
      card_class = component { prop :title, types::Strict::String }

      expect { card_class.new(title: 1) }
        .to raise_error(Phlex::Hanami::InvalidPropError, /invalid :title prop/) { |error|
          expect(error.cause).to be_a(Dry::Types::ConstraintError)
        }
    end

    it "uses the type's own default when the keyword is left out" do
      types = self.types
      card = component { prop :compact, types::Params::Bool.default(false) }.new

      expect(ivar(card, :compact)).to be(false)
    end
  end

  describe "a plain class" do
    it "accepts a value it matches" do
      card = component { prop :title, String }.new(title: "Hello")

      expect(ivar(card, :title)).to eq("Hello")
    end

    it "raises for a value it does not match" do
      expect { component { prop :title, String }.new(title: 1) }
        .to raise_error(Phlex::Hanami::InvalidPropError, /1 is not a String/)
    end
  end

  describe "defaults" do
    it "makes the keyword optional" do
      card = component { prop :compact, Object, default: false }.new

      expect(ivar(card, :compact)).to be(false)
    end

    it "calls a proc for each instance" do
      card_class = component { prop :tags, Array, default: -> { [] } }

      expect(ivar(card_class.new, :tags)).not_to be(ivar(card_class.new, :tags))
    end

    it "runs the default through the type" do
      types = self.types
      card = component { prop :count, types::Params::Integer, default: "3" }.new

      expect(ivar(card, :count)).to eq(3)
    end

    it "keeps an explicit nil rather than treating it as missing" do
      card = component { prop :title, NilClass, default: :unused }.new(title: nil)

      expect(ivar(card, :title)).to be_nil
    end
  end

  describe "a nilable type" do
    it "makes a dry type built with optional optional" do
      types = self.types
      card = component { prop :title, types::Strict::String.optional }.new

      expect(ivar(card, :title)).to be_nil
    end

    it "makes a type that matches nil optional" do
      card = component { prop :title, NilClass }.new

      expect(ivar(card, :title)).to be_nil
    end
  end

  describe "prop?" do
    it "leaves UNSET in the instance variable when the keyword is left out" do
      types = self.types
      card = component { prop? :token, types::Strict::String.optional }.new

      expect(ivar(card, :token)).to be(Phlex::Hanami::Props::UNSET)
    end

    it "keeps an explicit nil" do
      types = self.types
      card = component { prop? :token, types::Strict::String.optional }.new(token: nil)

      expect(ivar(card, :token)).to be_nil
    end

    it "runs a value it is given through the type" do
      expect { component { prop? :token, String }.new(token: 1) }.to raise_error(Phlex::Hanami::InvalidPropError)
    end

    it "takes a positional kind" do
      card_class = component { prop? :title, String, :positional }

      expect(ivar(card_class.new, :title)).to be(Phlex::Hanami::Props::UNSET)
      expect(ivar(card_class.new("Hello"), :title)).to eq("Hello")
    end

    it "rejects a splat kind" do
      expect { component { prop? :rest, Hash, :** } }.to raise_error(ArgumentError, /:keyword or :positional/)
    end
  end

  describe "kinds" do
    it "collects the keywords no other prop declares with :**" do
      card = component do
        prop :title, String
        prop :attributes, Hash, :**
      end.new(title: "Hello", id: "card", data: { x: 1 })

      expect(ivar(card, :title)).to eq("Hello")
      expect(ivar(card, :attributes)).to eq(id: "card", data: { x: 1 })
    end

    it "checks the collected keywords against the type" do
      types = self.types
      card_class = component { prop :attributes, types::Hash.map(types::Symbol, types::Strict::String), :** }

      expect { card_class.new(id: 1) }.to raise_error(Phlex::Hanami::InvalidPropError, /:attributes/)
    end

    it "takes a positional argument" do
      card = component { prop :title, String, :positional }.new("Hello")

      expect(ivar(card, :title)).to eq("Hello")
    end

    it "collects the rest of the positional arguments with :*" do
      card = component do
        prop :first, String, :positional
        prop :rest, Array, :*
      end.new("a", "b", "c")

      expect(ivar(card, :rest)).to eq(%w[b c])
    end

    it "declares each kind in the order Ruby needs" do
      card_class = component do
        prop :attributes, Hash, :**
        prop :title, String
        prop :rest, Array, :*
        prop :first, String, :positional
      end

      expect(card_class.instance_method(:initialize).parameters)
        .to eq([%i[req __first__], %i[rest __rest__], %i[keyreq title], %i[keyrest __attributes__]])
    end

    it "accepts a positional prop named after a reserved word" do
      card = component { prop :class, String, :positional }.new("wide")

      expect(ivar(card, :class)).to eq("wide")
    end

    it "rejects a second :** prop" do
      expect do
        component do
          prop :attributes, Hash, :**
          prop :other, Hash, :**
        end
      end.to raise_error(ArgumentError, /already has a :\*\* prop/)
    end

    it "rejects a default on a splat" do
      expect { component { prop :attributes, Hash, :**, default: {} } }.to raise_error(ArgumentError, /default/)
    end

    it "rejects a required positional prop after an optional one" do
      expect do
        component do
          prop :first, String, :positional, default: "a"
          prop :second, String, :positional
        end
      end.to raise_error(ArgumentError, /follows an optional one/)
    end

    it "rejects an unknown kind" do
      expect { component { prop :title, String, :block } }.to raise_error(ArgumentError, /kind must be one of/)
    end
  end

  describe "coercion" do
    it "runs the block on the instance before the type" do
      card = component do
        prop :title, String do |value|
          "#{prefix}#{value}"
        end

        def prefix = "> "
      end.new(title: 1)

      expect(ivar(card, :title)).to eq("> 1")
    end

    it "runs the block on a default" do
      card = component { prop(:title, String, default: "hi", &:upcase) }.new

      expect(ivar(card, :title)).to eq("HI")
    end
  end

  describe "methods" do
    it "defines a reader" do
      card = component { prop :title, String, reader: :public }.new(title: "Hello")

      expect(card.title).to eq("Hello")
    end

    it "gives the reader the visibility asked for" do
      card_class = component { prop :title, String, reader: :private }

      expect(card_class.private_method_defined?(:title)).to be(true)
    end

    it "defines a writer that checks the type" do
      card = component { prop :title, String, writer: :public }.new(title: "Hello")
      card.title = "Bye"

      expect(ivar(card, :title)).to eq("Bye")
      expect { card.title = 1 }.to raise_error(Phlex::Hanami::InvalidPropError)
    end

    it "defines a predicate" do
      card_class = component { prop :compact, Object, default: false, predicate: :public }

      expect(card_class.new.compact?).to be(false)
      expect(card_class.new(compact: 1).compact?).to be(true)
    end

    it "rejects a visibility it does not know" do
      expect { component { prop :title, String, reader: :open } }.to raise_error(ArgumentError, /reader must be one of/)
    end

    it "rejects a reader for :class" do
      expect { component { prop :class, String, reader: :public } }.to raise_error(ArgumentError, /:class/)
    end
  end

  it "calls after_initialize once the props are set" do
    card = component do
      prop :title, String, reader: :private

      def after_initialize = @shout = title.upcase
    end.new(title: "hello")

    expect(ivar(card, :shout)).to eq("HELLO")
  end

  it "runs a default proc on the instance, after the props above it" do
    card = component do
      prop :title, String, reader: :private
      prop :heading, String, default: -> { title.upcase }
    end.new(title: "hello")

    expect(ivar(card, :heading)).to eq("HELLO")
  end

  it "requires a prop with no default" do
    expect { component { prop :title, String }.new }.to raise_error(ArgumentError, /title/)
  end

  it "declares real keywords, which is what auto render filters input by" do
    card_class = component do
      prop :title, String
      prop :compact, Object, default: false
    end

    expect(card_class.instance_method(:initialize).parameters).to eq([%i[keyreq title], %i[key compact]])
  end

  it "accepts a prop named after a reserved word" do
    card = component { prop :class, String }.new(class: "wide")

    expect(ivar(card, :class)).to eq("wide")
  end

  it "rejects a name that is not a Ruby identifier" do
    expect { component { prop :"a-b", String } }.to raise_error(ArgumentError, /not a valid prop name/)
  end

  it "inherits a superclass's props" do
    parent = component { prop :title, String }
    child = Class.new(parent) { prop :count, Integer }

    expect(ivar(child.new(title: "Hello", count: 1), :title)).to eq("Hello")
  end

  it "lets a class define its own initialize and call super" do
    card_class = component do
      prop :title, String

      def initialize(title:)
        super(title: title.upcase)
      end
    end

    expect(ivar(card_class.new(title: "hello"), :title)).to eq("HELLO")
  end

  describe "auto render", type: :request do
    it "coerces a request param" do
      get "/posts/-/paged?page=2&stray=1"

      expect(last_response.body).to eq("<p>Integer 2</p>")
    end

    it "falls back to the type's default when the param is missing" do
      get "/posts/-/paged"

      expect(last_response.body).to eq("<p>Integer 1</p>")
    end
  end
end
