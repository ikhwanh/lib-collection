module Notifme
  module Notifable
    extend ActiveSupport::Concern

    included do
      scope :read, -> { where.not(read_at: nil) }
      scope :unread, -> { where(read_at: nil) }
    end

    class_methods do
      def mark_as_read!
        update_all(read_at: DateTime.current)
      end
    end

    def read?
      read_at?
    end

    def unread?
      !read?
    end
  end
end
