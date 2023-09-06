class User < ApplicationRecord
  has_many :enrollments
  has_many :teacher_enrollments, foreign_key: :teacher_id, class_name: "Enrollment"

  enum kind: {
    student_kind: 0,
    teacher_kind: 1,
    user_kind: 2
  }

  scope :classmates, -> (user) {
    program_ids, teacher_ids = [], []
    user.enrollments.each{ |record| program_ids << record.program_id; teacher_ids << record.teacher_id }

    includes(:enrollments).distinct.where(enrollments: { program_id: program_ids.uniq, teacher_id: teacher_ids.uniq })
                       .where.not(enrollments: { user_id: user.id })
  }

  has_many :teachers, through: :enrollments, foreign_key: 'teacher_id', class_name: 'User'
  validate :validate_kind, on: :update


  def self.favorites
    where("enrollments.favorite IS TRUE")
  end

  def teacher?
    self.kind == 'teacher_kind'
  end

  def student?
    self.kind == 'student_kind'
  end

  private

  def validate_kind
    case self.kind
    when 'student_kind'
      if Enrollment.all_teacher_ids.include?(self.id)
        self.errors.add(:kind, "can not be student because is teaching in at least one program")
      end
    when 'teacher_kind'
      if Enrollment.all_student_ids.include?(self.id)
        self.errors.add(:kind, "can not be teacher because is studying in at least one program")
      end
    end
  end
end
