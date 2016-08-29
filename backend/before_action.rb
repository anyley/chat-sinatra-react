module Utils
  module Callbacks
    def before_action(hook, *names)
      @___before ||= Hash.new([])
      names.each { |n| @___before[n] += [hook] }
    end

    def method_added(name)
      return if !@___before || @___before[name].empty?
      return if (@___methods_with_hooks ||= []).include?(name)

      method = instance_method(name)
      hooks = @___before[name]
      @___methods_with_hooks << name

      define_method(name) do |*args, &block|
        hooks.each { |hook| send(hook, *args) }
        method.bind(self).call(*args, &block)
      end
    end
  end
end



# class FilterTest2
#   extend Utils::Callbacks

#   before_action :hook, :baz3
#   before_action :hook2, :baz3

#   def hook
#     puts "HOOK 1: #{@inst}"
#   end
  
#   def hook2
#     puts "HOOK 2: #{@inst}"
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
