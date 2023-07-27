module Koyo::Repl::Mod
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    attr_accessor :koyo_repl_handler_method

    def koyo_repl_handler(n)
      @koyo_repl_handler_method = n
    end
  end
end
