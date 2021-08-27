module Notifme
  autoload :Notifable, 'notifme/notifable'
  autoload :Base, 'notifme/base'

  module DeliveryMethods
    autoload :Base, 'notifme/delivery_methods/base'
    autoload :Database, 'notifme/delivery_methods/database'
    autoload :Email, 'notifme/delivery_methods/email'
  end
end
