class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validate :email_domain
  has_many :listings, :dependent => :destroy

  def email_domain
    domain = email.split('@').last
    errors.add(:email, 'Invalid Domain') if domain != 'uno.edu' && email.present?
  end

  def set_to_grid_view
    logger.debug "In user model: About to set view to grid - was: #{listing_view_type}"
    update_attribute(:listing_view_type, 'grid')
  end

  def set_to_list_view
    logger.debug "In user model: About to set view to list - was: #{listing_view_type}"
    update_attribute(:listing_view_type, 'list')
  end
end

