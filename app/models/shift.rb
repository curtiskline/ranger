class Shift < ActiveRecord::Base
  belongs_to :event
  has_many :slots, :dependent => :destroy
  has_many :positions, through: :slots
  has_many :work_logs
  has_one :training, :dependent => :destroy # iff event type is TrainingSeason
  attr_accessible :name, :description, :start_time, :end_time, :event_id
  accepts_nested_attributes_for :training

  audited associated_with: :event
  has_associated_audits

  self.per_page = 50

  validates :name, :start_time, :end_time, :event, :presence => true
  validates_presence_of :training, :if => Proc.new {|shift| shift.event.is_a? TrainingSeason}
  validates_with DateOrderValidator, :start => :start_time, :end => :end_time
  validates_with ReasonableDateValidator,
    :attributes => [:start_time, :end_time]
  # TODO validate start/end overlap with event's start/end?

  default_scope order('start_time, end_time, name')
  scope :with_positions, lambda {|position_ids|
    includes(:slots).where('slots.position_id IN (?)', position_ids).uniq}
  scope :overlapping, lambda {|range_or_start, end_time=nil|
    if range_or_start.respond_to?(:min)
      t1, t2 = range_or_start.min, range_or_start.max
    elsif end_time
      r = [range_or_start, end_time]
      t1, t2 = r.min, r.max
    else
      t1, t2 = range_or_start, range_or_start
    end
    where('end_time > ? and start_time < ?', t1, t2)
  }

  before_validation do |shift|
    if shift.event.is_a? TrainingSeason and shift.training.blank?
      shift.build_training
      shift.training.shift = shift
    end
  end

  def duration_seconds
    end_time.to_i - start_time.to_i
  end

  def create_slots_from_template(shift_template)
    shift_template.slot_templates.map do |t|
      slots.create position_id: t.position_id, min_people: t.min_people, max_people: t.max_people
    end
  end

  def merge_from_template!(shift_template, date = nil)
    t = shift_template
    default_date = event ? event.start_date : Time.zone.now
    d = case date
        when nil then default_date
        when /^\s*$/ then default_date
        when String then Time.zone.parse(date) || default_date
        when Fixnum then Time.zone.at(date)
        else date
        end
    self.name = t.name if t.name.present?
    self.description = t.description if t.description.present?
    self.start_time =
      Time.zone.local(d.year, d.month, d.day, t.start_hour, t.start_minute)
    self.end_time =
      Time.zone.local(d.year, d.month, d.day, t.end_hour, t.end_minute)
    self.end_time += 1.day if end_time < start_time
  end

  def to_s_with_date
    starts = "#{I18n.l start_time, :format => :short}"
    ends = "#{I18n.l end_time, :format => :short}"
    "#{name} #{starts} - #{ends}"
  end
end
