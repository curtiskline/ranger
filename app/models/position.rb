class Position < ActiveRecord::Base
  has_and_belongs_to_many :people
  has_many :work_logs

  validates :name, :presence => true
end