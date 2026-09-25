# frozen_string_literal: true

module Phlex
  module Hanami
    # Declared props, typed with dry-types.
    #
    # Opt in per class. Each `prop` names a keyword `initialize` takes and the type its value goes
    # through, and the value lands in an instance variable of the same name. A dry type is called,
    # so it coerces as well as checks: `Types::Params::Integer` turns the string a request param
    # arrives as into an Integer. Anything else that answers `call` is called the same way, and
    # anything that does not, such as a plain class, is matched with `===`.
    #
    # The initializer it builds takes real keywords, so auto render hands a view the props it
    # declares and drops every other param, the same as it does for a hand written `initialize`.
    #
    # Literal needs none of this. Extend `Literal::Properties` instead if you would rather use it.
    #
    # @example
    #   class Card < Phlex::Hanami::Component
    #     include Phlex::Hanami::Props
    #
    #     prop :post, Types::Instance(Post)
    #     prop :count, Types::Params::Integer
    #     prop :compact, Types::Bool, default: false
    #     prop :tags, Types::Array.of(Types::String), default: -> { [] }
    #
    #     def view_template
    #       article(class: ("compact" if @compact)) { h2 { @post.title } }
    #     end
    #   end
    #
    # @api public
    # @since 0.3.0
    module Props
      # Stands in for a keyword the caller left out, since `nil` can be a real value.
      #
      # @api private
      # @since 0.3.0
      UNSET = ::Object.new.freeze #: Object

      # How the generated initializer names {UNSET}.
      #
      # @api private
      # @since 0.3.0
      UNSET_PATH = "::Phlex::Hanami::Props::UNSET" #: String

      # A prop name has to be a Ruby identifier, because it becomes a keyword and an instance
      # variable.
      #
      # @api private
      # @since 0.3.0
      NAME_FORMAT = /\A[a-z_][a-zA-Z0-9_]*\z/ #: Regexp

      # Sets each prop's instance variable from the keywords the generated initializer received.
      #
      # @api private
      # @since 0.3.0
      #: (untyped, Binding) -> void
      def self.assign(view, arguments)
        view.class.props.each_value do |prop|
          value = prop.resolve(view.class, arguments.local_variable_get(prop.name))
          view.instance_variable_set(:"@#{prop.name}", value)
        end
      end

      # @api private
      # @since 0.3.0
      #: (Module) -> void
      def self.included(view_class)
        view_class.extend(ClassMethods)
      end

      # @api public
      # @since 0.3.0
      module ClassMethods
        # Declares a prop.
        #
        # A prop with a default is optional. So is one whose dry type carries its own, as
        # `Types::Bool.default(false)` does. A default goes through the type like any other value.
        # Pass a proc for anything mutable, so each instance gets its own.
        #
        # @param name [Symbol] the keyword, and the instance variable the value lands in
        # @param type [#call, #===] a dry type, or anything that answers `call` or `===`
        # @param default [Object, Proc] the value when the keyword is left out
        #
        # @return [Symbol] the name
        #
        # @raise [ArgumentError] if the name is not a Ruby identifier
        #
        # @api public
        # @since 0.3.0
        #: (Symbol, untyped, ?default: untyped) -> Symbol
        def prop(name, type, default: UNSET)
          raise ArgumentError, "#{name.inspect} is not a valid prop name" unless NAME_FORMAT.match?(name.to_s)

          own_props[name] = Prop.new(name, type, default)
          define_props_initializer
          name
        end

        # Every prop this class declares, its superclasses' first.
        #
        # @api public
        # @since 0.3.0
        #: () -> Hash[Symbol, Prop]
        def props
          inherited = superclass.respond_to?(:props) ? superclass.props : {} #: Hash[Symbol, Prop]
          inherited.merge(own_props)
        end

        private

        # Writes `initialize` into a module of its own rather than onto the class, so a class can
        # still define `initialize` and call `super`.
        #: () -> void
        def define_props_initializer
          @props_initializer ||= ::Module.new.tap { |initializer| include(initializer) }
          keywords = props.each_value.map { |prop| prop.optional? ? "#{prop.name}: #{UNSET_PATH}" : "#{prop.name}:" }
          signature = keywords.join(", ")

          # `binding` rather than the names themselves, because a prop may be named after a
          # reserved word such as `class`, which is a valid keyword but not a readable variable.
          @props_initializer.module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def initialize(#{signature})                     # def initialize(post:, compact: ::Phlex::Hanami::Props::UNSET)
              ::Phlex::Hanami::Props.assign(self, binding)  #   ::Phlex::Hanami::Props.assign(self, binding)
            end                                             # end
          RUBY
        end

        #: () -> Hash[Symbol, Prop]
        def own_props
          @own_props ||= {}
        end
      end

      # One declared prop.
      #
      # @api private
      # @since 0.3.0
      class Prop
        attr_reader :name #: Symbol

        #: (Symbol, untyped, untyped) -> void
        def initialize(name, type, default)
          @name = name
          @type = type
          @default = default
        end

        # Whether the keyword can be left out.
        #
        #: () -> bool
        def optional?
          !UNSET.equal?(@default) || type_default?
        end

        # The value to assign, given what the caller passed or {UNSET}.
        #
        # @raise [InvalidPropError] if the type rejects the value
        #
        #: (Module, untyped) -> untyped
        def resolve(view_class, value)
          if UNSET.equal?(value)
            return @type.call if UNSET.equal?(@default)

            value = @default.is_a?(::Proc) ? @default.call : @default
          end

          cast(view_class, value)
        end

        private

        #: (Module, untyped) -> untyped
        def cast(view_class, value)
          if @type.respond_to?(:call)
            begin
              return @type.call(value)
            rescue StandardError => e
              raise InvalidPropError.new(view_class, @name, e.message)
            end
          end

          return value if @type === value # rubocop:disable Style/CaseEquality

          raise InvalidPropError.new(view_class, @name, "#{value.inspect} is not a #{@type.inspect}")
        end

        # A dry type built with `.default` fills in a missing value itself.
        #: () -> bool
        def type_default?
          @type.respond_to?(:default?) && @type.default?
        end
      end
    end
  end
end
