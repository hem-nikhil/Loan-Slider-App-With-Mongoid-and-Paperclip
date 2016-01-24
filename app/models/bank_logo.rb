class BankLogo
  include Mongoid::Document
  include Mongoid::Paperclip

  field :bank_name, type: String

  has_mongoid_attached_file :logo, :url => "/:class/:attachment/:id/:style_:basename.:extension"
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]


  class << self
    def get_bank_images(bank_names)
      bank_logos = {}
      self.in(bank_name: bank_names).each do|bank_logo_info|
        bank_logos[bank_logo_info.bank_name] = bank_logo_info.logo
      end
      bank_logos
    end
  end

end
