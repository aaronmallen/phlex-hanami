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
