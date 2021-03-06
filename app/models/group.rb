class Group < ApplicationRecord
  include Sluggable

  has_many :events
  has_many :members do
    def for_user(user)
      user_id = user.respond_to?(:id) ? user.id : user.to_i
      detect { |member| member.user_id == user_id }
    end
  end

  scope :with_members, -> { includes(members: :user) }
end
