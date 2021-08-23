class Course < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  validates :title, :description, :short_description, :level, :language, :price, presence: true
  validates :title, uniqueness: true
  has_rich_text :description

  belongs_to :author, class_name: 'User', foreign_key: :user_id, counter_cache: true
  # User.find_each { |user| User.reset_counters(user.id, :courses) }
  has_many :lessons, dependent: :destroy
  has_many :enrollments
  has_many :student_lessons, through: :lessons

  scope :popular, -> { order(enrollments_count: :desc).first(3) }
  scope :top_rated, -> { order(average_rating: :desc).first(3) }
  scope :newly_added, -> { order(created_at: :desc).first(3) }

  LANGUAGES = %w[English Tagalog Russian].freeze
  LEVELS = %w[Beginner Intermediate Advanced].freeze

  def to_s
    title
  end

  def update_rating
    update_attribute(:average_rating, enrollments.merge(Enrollment.rated).average(:rating).to_f.round(2))
  end

  def progress(student)
    return 0 if lessons_count.zero?

    student_lessons.where(student: student).count / lessons_count.to_f * 100
  end
end
