require "daru"

module Daru
  module WhereDSL
    class BinaryOp
      def initialize(op, left, right)
        @op = op
        @left = left
        @right = right
      end

      def to_where_arg(df)
        left = vectorize_symbol(@left, df)
        right = vectorize_symbol(@right, df)
        mod = Daru::Core::Query
        if right.is_a?(Daru::Vector)
          mod.apply_vector_operator(@op, left, right)
        else
          mod.apply_scalar_operator(@op, left.instance_variable_get(:@data),
                                    right)
        end
      end

      def vectorize_symbol(obj, df)
        if obj.is_a?(Symbol)
          df[obj]
        else
          obj
        end
      end

      [:&, :|].each do |op|
        define_method(op) do |other|
          LogicalOp.new(op, self, other)
        end
      end
    end

    class LogicalOp
      def initialize(op, left, right)
        @op = op
        @left = left
        @right = right
      end

      def to_where_arg(df)
        @left.to_where_arg(df).send(@op, @right.to_where_arg(df))
      end
    end

    refine Symbol do
      [:==, :!=, :<, :<=, :>, :>=].each do |op|
        define_method(op) do |other|
          BinaryOp.new(op, self, other)
        end
      end
    end
  end

  module Refinements
    refine Daru::DataFrame do
      def where(*args, &block)
        if block
          if args.length > 0
            raise ArgumentError, "both argument and block given"
          end
          arg = instance_eval(using: WhereDSL, &block).to_where_arg(self)
          super(arg)
        else
          super(*args)
        end
      end
    end
  end
end
