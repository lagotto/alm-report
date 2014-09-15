# Used for instruments throughout the app, automatically adding class and
# method name. Used like so:
# def YourClass
#   def your_method(payload)
#     measure(payload) do
#       code_to_measure
#     end
#   end
# end
# This will fire an event with the name of "YourClass.your_method", to which you
# can subscribe.
# For an example look at config/initializers/performance_logging.rb

module Performance
  def self.included(base)
    base.send :include, Methods
    base.extend Methods
  end

  module Methods
    def measure(payload, &block)
      method_name = block.binding.eval("self.name + '.' + __method__.to_s")
      ActiveSupport::Notifications.instrument(method_name, payload) do
        block.call
      end
    end
  end
end
