# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true
  validate :cannnot_set_eyecatch_when_not_premium
  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where("title LIKE '%#{term}%' OR content LIKE '%#{term}%'")
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end

  def cannnot_set_eyecatch_when_not_premium
    return unless !user.premium && random_eyecatch

    self.random_eyecatch = false
  end
end
