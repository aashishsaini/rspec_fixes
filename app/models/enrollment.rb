class Enrollment < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  belongs_to :teacher, foreign_key: :teacher_id, class_name: 'User'
  belongs_to :program

  scope :all_teacher_ids, -> { map(&:teacher_id).compact }
  scope :all_student_ids, -> { map(&:user_id).compact }

  # scope :favorites, -> { where(favorite: true).map(&:teacher) }
end
