class Enrollment < ApplicationRecord
  extend FriendlyId
  friendly_id :to_s, use: :slugged

  belongs_to :course
  belongs_to :student, class_name: 'User', foreign_key: 'student_id'

  validates_presence_of :rating, if: :review?
  validates_presence_of :review, if: :rating?

  validates_uniqueness_of :student_id, scope: :course_id
  validates_uniqueness_of :course_id, scope: :student_id

  validate :cant_enroll_to_own_course, on: :create

  scope :pending_review, -> { where(rating: [0, nil, ''], review: [0, nil, '']) }

  after_commit do
    course.update_rating unless rating.to_i.zero?
  end

  after_destroy do
    course.update_rating
  end

  def to_s
    [student.to_s, course.to_s].join ' '
  end

  private

  def cant_enroll_to_own_course
    errors.add(:base, 'You can not enroll to your own course') if course && course.author == student
  end
end
