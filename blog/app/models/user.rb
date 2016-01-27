# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :presence => true,
                   :length => {:maximum => 15, :minimum => 4}
  validates :email, :presence => true,
                    :format => {:with => email_regex},
                    :uniqueness => { :case_sensitive => false }

                    # Aqui se genera el atributo virtual password_confirmation (true)
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => {:within => 6..20}


 before_save :encrypt_password

 # True if submitted password matches user's hashed password
 def has_password?(submitted_password)
   self.encrypted_password == encrypt(submitted_password)
 end

 private
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encryped_password = encrypt(self.password)
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{self.password}")
  end

  def secure_hash(string)
      Digest::SHA2.hexdigest(string)
  end

end