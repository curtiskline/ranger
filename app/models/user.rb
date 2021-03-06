class User < ActiveRecord::Base
  include EmailHelper

  # If true, the first user created is an admin. Disable for conversion.
  cattr_accessor :first_user_is_admin do true end

  audited associated_with: :person,
    except: [:encrypted_password, :reset_password_token, :remember_created_at,
      :sign_in_count, :current_sign_in_at, :last_sign_in_at,
      :current_sign_in_ip, :last_sign_in_ip]
  has_associated_audits

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # TODO restore :registerable when we have firm plans about new volunteer flow

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :person_attributes, :disabled, :disabled_message

  belongs_to :person
  # TODO don't let person change after creation
  has_many :user_roles, :dependent => :destroy

  validates :email, :uniqueness => true, :presence => true,
    :format => EmailHelper::VALID_EMAIL

  def active_for_authentication?
    super and not disabled?
  end

  def inactive_message
    disabled? ? disabled_message || super : super
  end

  def roles
    @roles ||= user_roles.map {|ur| Role[ur.role]}
  end

  def masked_roles
    @masked_roles
  end

  def masked_roles=(masked_roles)
    @masked_roles = masked_roles.map {|r| Role[r]}.select(&:present?)
  end

  def has_role?(*roles_or_syms_or_strings)
    roles_or_syms_or_strings.any? do |role|
      r = Role[role]
      r.in?(roles) and not r.in?(masked_roles || [])
    end
  end

  def to_title
    person ? person.to_s : email
  end

  def to_s
    to_title
  end

  before_validation do |u|
    if u.new_record?
      u.email = u.person.email if u.email.blank? && u.person
    end
    u.email = User.normalize_email u.email
  end

  before_create do |u|
    # Make the first user an admin
    if first_user_is_admin and u.roles.empty? and User.count == 0
      u.user_roles.build(:role => :admin)
    end
  end
end
