module Notifme
  module DeliveryMethods
    class Base < ActiveJob::Base
      def perform(args)
        @name = args[:name]
        deliver
      end

      def deliver
        raise NotImplementedError
      end
    end
  end
end
