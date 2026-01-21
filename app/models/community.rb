class Community < ApplicationRecord
  # Concernを読み込み
  include CommunityValidatable
  include CommunityScopeable
  include CommunityMembershipManageable
  include CommunityStatisticsCalculable

  # アソシエーション
  belongs_to :creator, class_name: 'User'
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :community_threads, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :replies, through: :community_threads, dependent: :destroy
end
