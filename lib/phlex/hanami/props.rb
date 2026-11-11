# frozen_string_literal: true

module Phlex
  module Hanami
    # Declared props, typed with dry-types.
    #
    # Opt in per class. Each `prop` names an argument `initialize` takes and the type its value goes
    # through, and the value lands in an instance variable of the same name. A dry type is called,
    # so it coerces as well as checks: `Types::Params::Integer` turns the string a request param
    # arrives as into an Integer. Anything else that answers `call` is called the same way, and
    # anything that does not, such as a plain class, is matched with `===`.
    #
    # The initializer it builds takes real keywords, so auto render hands a view the props it
    # declares and drops every other param, the same as it does for a hand written `initialize`. A
    # `:**` prop takes them all, request params included.
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
    #     prop :attributes, Types::Hash, :**
    #
    #     def view_template
    #       article(class: ("compact" if @compact), **@attributes) { h2 { @post.title } }
    #     end
    #   end
    #
    # @api public
    # @since 0.2.1
    module Props
      # The value of a prop declared with `prop?` that the caller left out, so a view can tell it
      # from `nil`.
      #
      # @example
      #   prop? :token, Types::String.optional
      #
      #   def token_given? = !Phlex::Hanami::Props::UNSET.equal?(@token)
      #
      # @api public
      # @since 0.2.1
      UNSET = ::Object.new.tap { |unset| def unset.inspect = "Phlex::Hanami::Props::UNSET" }.freeze #: Object

      # How the generated initializer names {UNSET}.
      #
      # @api private
      # @since 0.2.1
      UNSET_PATH = "::Phlex::Hanami::Props::UNSET" #: String

      # A prop name has to be a Ruby identifier, because it becomes an argument and an instance
      # variable.
      #
      # @api private
      # @since 0.2.1
      NAME_FORMAT = /\A[a-z_][a-zA-Z0-9_]*\z/ #: Regexp

      # The argument kinds a prop can take, in the order `initialize` declares them.
      #
      # @api private
      # @since 0.3.0
      KINDS = %i[positional * keyword **].freeze #: Array[Symbol]

      # What `reader`, `writer` and `predicate` accept.
      #
      # @api private
      # @since 0.3.0
      VISIBILITIES = [false, :public, :protected, :private].freeze #: Array[Symbol | false]

      # Sets each prop's instance variable from the arguments the generated initializer received.
      #
      # @api private
      # @since 0.2.1
      #: (untyped, Binding) -> void
      def self.assign(view, arguments)
        view.class.props.each_value do |prop|
          value = prop.resolve(view, arguments.local_variable_get(prop.variable))
          view.instance_variable_set(:"@#{prop.name}", value)
        end
      end

      # @api private
      # @since 0.2.1
      #: (Module) -> void
      def self.included(view_class)
        view_class.extend(ClassMethods)
      end

      # @api public
      # @since 0.2.1
      module ClassMethods
        # Declares a prop.
        #
        # A prop with a default is optional. So is one whose type accepts nil, which it gets when
        # left out, and one whose dry type carries its own default, as `Types::Bool.default(false)`
        # does. A default goes through the type like any other value. Pass a proc for anything
        # mutable, so each instance gets its own. The proc runs on the new instance, so it can read
        # the props declared above it.
        #
        # A block, when given, runs on the new instance with the value before the type sees it.
        #
        # @param name [Symbol] the argument, and the instance variable the value lands in
        # @param type [#call, #===] a dry type, or anything that answers `call` or `===`
        # @param kind [Symbol] `:keyword`, `:positional`, `:*` for the rest of the positional
        #   arguments as an Array, or `:**` for the rest of the keywords as a Hash
        # @param default [Object, Proc] the value when the argument is left out
        # @param reader [false, Symbol] the visibility of a reader method, or false for none
        # @param writer [false, Symbol] the visibility of a writer method that checks the type
        # @param predicate [false, Symbol] the visibility of a `name?` method
        #
        # @return [Symbol] the name
        #
        # @raise [ArgumentError] if an option is not valid, or the argument would not fit the
        #   ones declared before it
        #
        # @api public
        # @since 0.2.1
        # @rbs name: Symbol
        # @rbs type: untyped
        # @rbs kind: Symbol
        # @rbs default: untyped
        # @rbs reader: Symbol | false
        # @rbs writer: Symbol | false
        # @rbs predicate: Symbol | false
        # @rbs &coercion: ? (untyped) -> untyped
        # @rbs return: Symbol
        def prop(name, type, kind = :keyword, default: UNSET, reader: false, writer: false, predicate: false, &coercion)
          prop = Prop.new(name, type, kind, default:, omittable: false, coercion:)
          declare_prop(prop, { reader:, writer:, predicate: })
        end

        # Declares a prop the caller can leave out, and that is set to {UNSET} when they do. A view
        # can then tell an argument left out from one passed as `nil`.
        #
        # The type does not see {UNSET}, so it only has to accept what a caller passes.
        #
        # @param name [Symbol] the argument, and the instance variable the value lands in
        # @param type [#call, #===] a dry type, or anything that answers `call` or `===`
        # @param kind [Symbol] `:keyword` or `:positional`
        # @param reader [false, Symbol] the visibility of a reader method, or false for none
        # @param writer [false, Symbol] the visibility of a writer method that checks the type
        # @param predicate [false, Symbol] the visibility of a `name?` method
        #
        # @return [Symbol] the name
        #
        # @raise [ArgumentError] if an option is not valid, or the argument would not fit the
        #   ones declared before it
        #
        # @api public
        # @since 0.3.0
        # @rbs name: Symbol
        # @rbs type: untyped
        # @rbs kind: Symbol
        # @rbs reader: Symbol | false
        # @rbs writer: Symbol | false
        # @rbs predicate: Symbol | false
        # @rbs &coercion: ? (untyped) -> untyped
        # @rbs return: Symbol
        def prop?(name, type, kind = :keyword, reader: false, writer: false, predicate: false, &coercion)
          raise ArgumentError, "prop? takes a :keyword or :positional kind" unless %i[keyword positional].include?(kind)

          prop = Prop.new(name, type, kind, default: UNSET, omittable: true, coercion:)
          declare_prop(prop, { reader:, writer:, predicate: })
        end

        # Every prop this class declares, its superclasses' first.
        #
        # @api public
        # @since 0.2.1
        #: () -> Hash[Symbol, Prop]
        def props
          inherited = superclass.respond_to?(:props) ? superclass.props : {} #: Hash[Symbol, Prop]
          inherited.merge(own_props)
        end

        private

        #: (Prop, Hash[Symbol, Symbol | false]) -> void
        def check_methods(prop, methods)
          methods.each do |option, visibility|
            next if VISIBILITIES.include?(visibility)

            raise ArgumentError, "#{option} must be one of #{VISIBILITIES.map(&:inspect).join(', ')}"
          end

          # A reader would replace `Object#class`, which Phlex and Hanami both call.
          raise ArgumentError, "the :class prop cannot have a reader" if methods[:reader] && prop.name == :class
        end

        # Ruby allows no required positional argument after an optional one once there is a `*`,
        # and the order would surprise a caller anyway.
        #: (Prop, Array[Prop]) -> void
        def check_positional_order(prop, others)
          return unless prop.kind == :positional && !prop.optional?
          return unless others.any? { |other| other.kind == :positional && other.optional? }

          raise ArgumentError, "the required positional prop #{prop.name.inspect} follows an optional one"
        end

        #: (Prop, Array[Prop]) -> void
        def check_splat(prop, others)
          return unless %i[* **].include?(prop.kind) && others.any? { |other| other.kind == prop.kind }

          raise ArgumentError, "#{self} already has a #{prop.kind.inspect} prop"
        end

        #: (Prop, Hash[Symbol, Symbol | false]) -> Symbol
        def declare_prop(prop, methods)
          others = props.reject { |name, _| name == prop.name }.values
          check_methods(prop, methods)
          check_splat(prop, others)
          check_positional_order(prop, others)

          own_props[prop.name] = prop
          define_props_initializer
          define_prop_methods(prop, methods)
          prop.name
        end

        #: (Prop, Symbol) -> Symbol
        def define_prop_method(prop, option)
          ivar = :"@#{prop.name}"

          case option
          when :reader then props_module.define_method(prop.name) { instance_variable_get(ivar) }
          when :predicate then props_module.define_method(:"#{prop.name}?") { !!instance_variable_get(ivar) }
          else define_prop_writer(prop)
          end
        end

        # Defines the reader, writer and predicate asked for, each with its own visibility.
        #: (Prop, Hash[Symbol, Symbol | false]) -> void
        def define_prop_methods(prop, methods)
          methods.each do |option, visibility|
            props_module.send(visibility, define_prop_method(prop, option)) if visibility
          end
        end

        # A writer runs the value through the type, as `initialize` does.
        #: (Prop) -> Symbol
        def define_prop_writer(prop)
          ivar = :"@#{prop.name}"

          props_module.define_method(:"#{prop.name}=") do |value|
            instance_variable_set(ivar, prop.cast(self.class, value))
          end
        end

        # Writes `initialize` into a module of its own rather than onto the class, so a class can
        # still define `initialize` and call `super`.
        #: () -> void
        def define_props_initializer
          signature = props.values.sort_by.with_index { |prop, index| [KINDS.index(prop.kind), index] }.map(&:parameter)

          # `binding` rather than the names themselves, because a keyword may be named after a
          # reserved word such as `class`, which is a valid keyword but not a readable variable.
          props_module.module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def initialize(#{signature.join(', ')})                      # def initialize(post:, compact: ::Phlex::Hanami::Props::UNSET)
              ::Phlex::Hanami::Props.assign(self, binding)              #   ::Phlex::Hanami::Props.assign(self, binding)
              after_initialize if respond_to?(:after_initialize, true)  #   after_initialize if respond_to?(:after_initialize, true)
            end                                                         # end
          RUBY
        end

        #: () -> Hash[Symbol, Prop]
        def own_props
          @own_props ||= {}
        end

        #: () -> Module
        def props_module
          @props_module ||= ::Module.new.tap { |props_module| include(props_module) }
        end
      end

      # One declared prop.
      #
      # @api private
      # @since 0.2.1
      class Prop
        attr_reader :name #: Symbol

        attr_reader :kind #: Symbol

        #: (Symbol, untyped, Symbol, default: untyped, omittable: bool, coercion: Proc?) -> void
        def initialize(name, type, kind, default:, omittable:, coercion:)
          raise ArgumentError, "#{name.inspect} is not a valid prop name" unless NAME_FORMAT.match?(name.to_s)
          raise ArgumentError, "kind must be one of #{KINDS.map(&:inspect).join(', ')}" unless KINDS.include?(kind)
          raise ArgumentError, "a #{kind.inspect} prop cannot have a default" if splat?(kind) && !UNSET.equal?(default)

          @name = name
          @type = type
          @kind = kind
          @default = default
          @omittable = omittable
          @coercion = coercion
        end

        # Runs a value through the type.
        #
        # @raise [InvalidPropError] if the type rejects the value
        #
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

        # Whether the argument can be left out.
        #
        #: () -> bool
        def optional?
          @omittable || splat?(@kind) || !UNSET.equal?(@default) || type_default? || nilable?
        end

        # This prop's part of the generated initializer's signature.
        #
        #: () -> String
        def parameter
          case @kind
          when :keyword then optional? ? "#{@name}: #{UNSET_PATH}" : "#{@name}:"
          when :positional then optional? ? "#{variable} = #{UNSET_PATH}" : variable.to_s
          else "#{@kind}#{variable}"
          end
        end

        # The value to assign, given what the caller passed or {UNSET}.
        #
        # @raise [InvalidPropError] if the type rejects the value
        #
        #: (untyped, untyped) -> untyped
        def resolve(view, value)
          if UNSET.equal?(value)
            return UNSET if @omittable
            return @type.call if UNSET.equal?(@default) && type_default?

            value = default_value(view)
          end

          value = view.instance_exec(value, &@coercion) if @coercion
          cast(view.class, value)
        end

        # The local variable the generated initializer receives the value in. A keyword keeps its
        # name, since auto render reads it from the signature. Any other argument gets one that
        # cannot clash with a reserved word.
        #
        #: () -> Symbol
        def variable
          @kind == :keyword ? @name : :"__#{@name}__"
        end

        private

        # A prop with no default of its own is optional only because its type accepts nil.
        #: (untyped) -> untyped
        def default_value(view)
          return nil if UNSET.equal?(@default)

          @default.is_a?(::Proc) ? view.instance_exec(&@default) : @default
        end

        # A dry type built with `.optional`, or anything else that matches nil. A callable is left
        # out of the second test, since `===` on a Proc calls it.
        #: () -> bool
        def nilable?
          return @type.optional? if @type.respond_to?(:optional?)
          return false if @type.respond_to?(:call)

          @type === nil # rubocop:disable Style/CaseEquality, Style/NilComparison
        end

        #: (Symbol) -> bool
        def splat?(kind)
          %i[* **].include?(kind)
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
