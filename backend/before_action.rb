module Utils
  module Callbacks
    def before_action hook, *methods
      @___new_methods ||= []
      @___callbacks ||= {}
      @___callbacks[hook] = []
      methods.each do |m|
        @___callbacks[hook] << m
      end
    end

    def method_added name
      return unless instance_variable_defined? :@___callbacks
      return if @___new_methods.include? name
      @___callbacks.each do |blk, methods|
        if methods.include? name
          hidden_original = "___#{name}".to_sym
          @___new_methods.concat [hidden_original, name]
          alias_method hidden_original, name
          define_method name do |*args|
            self.send blk, *args
            self.send hidden_original.to_sym, *args
          end
          @___callbacks[blk].delete name
        end
      end
    end
  end
end



# class FilterTest2
#   extend Utils::Callbacks

#   before_action :hook, :baz3

#   def hook
#     puts "HOOK: #{@inst}"
#   end
  
#   def initialize
#     @inst = 111
#   end

#   def baz3
#     puts "baz 3"
#   end
# end

# ft2 = FilterTest2.new
# ft2.baz3
