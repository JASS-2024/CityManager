# typed: strong
# frozen_string_literal: true

module Homebrew
  # Subclass this to implement a `brew` command. This is preferred to declaring a named function in the `Homebrew`
  # module, because:
  # - Each Command lives in an isolated namespace.
  # - Each Command implements a defined interface.
  # - `args` is available as an ivar, and thus does not need to be passed as an argument to helper methods.
  #
  # To subclass, implement a `run` method and provide a `cmd_args` block to document the command and its allowed args.
  # To generate method signatures for command args, run `brew typecheck --update`.
  class AbstractCommand
    extend T::Helpers

    abstract!

    class << self
      sig { returns(String) }
      def command_name = Utils.underscore(T.must(name).split("::").fetch(-1)).tr("_", "-").delete_suffix("-cmd")

      # @return the AbstractCommand subclass associated with the brew CLI command name.
      sig { params(name: String).returns(T.nilable(T.class_of(AbstractCommand))) }
      def command(name) = subclasses.find { _1.command_name == name }

      sig { returns(CLI::Parser) }
      def parser = CLI::Parser.new(self, &@parser_block)

      private

      sig { params(block: T.proc.bind(CLI::Parser).void).void }
      def cmd_args(&block)
        @parser_block = T.let(block, T.nilable(T.proc.void))
      end
    end

    sig { returns(CLI::Args) }
    attr_reader :args

    sig { params(argv: T::Array[String]).void }
    def initialize(argv = ARGV.freeze)
      @args = T.let(self.class.parser.parse(argv), CLI::Args)
    end

    sig { abstract.void }
    def run; end
  end
end
