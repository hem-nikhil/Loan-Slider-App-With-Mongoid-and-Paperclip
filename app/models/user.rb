class User
  include Mongoid::Document

  # FIELDS = [:name,:email,:mobile_number,:residency_type,:empl_type,:loan_amount,:loan_tenure]
  # attr_accessor :name,:email,:mobile_number,:residency_type,:empl_type,:loan_amount,:loan_tenure
  field :name, type: String
  field :email, type: String
  field :mobile_number, type: Integer
  field :residency_type, type: String
  field :empl_type, type: String
  field :loan_amount, type:Float
  field :loan_tenure, type:Integer


  validates :name,:email,:mobile_number,:residency_type ,:empl_type,:loan_amount,:loan_tenure, presence: true
  validates :mobile_number, length: { minimum: 10, maximum: 10,message:"Please enter 10 digit mobile number"},
            numericality: { greater_than:0, only_integer: true }
  validates :email, email: true , uniqueness: { case_sensitive: false }

  validates :loan_amount, numericality: { greater_than_or_equal_to: GlobalConstant::LOAN_AMOUNT[:min_lower_amount],
                                          less_than_or_equal_to: GlobalConstant::LOAN_AMOUNT[:max_upper_amount],
                                          message:"Please Enter Positive Loan Amount Between #{GlobalConstant::LOAN_AMOUNT[:min_lower_amount]} and #{GlobalConstant::LOAN_AMOUNT[:max_upper_amount]}"}
  validates :loan_tenure, numericality: { greater_than_or_equal_to: GlobalConstant::LOAN_TENURE[:lower_tenure] ,
                                          less_than_or_equal_to: GlobalConstant::LOAN_TENURE[:upper_tenure] ,
                                          message:"Please Enter Positive Loan tenure Between #{ GlobalConstant::LOAN_TENURE[:lower_tenure]} and #{GlobalConstant::LOAN_TENURE[:upper_tenure]}",
                                          only_integer:true}


  class << self
    def create_user_entry(params)
      user = find_or_create_by(email: params[:email])
      user.name = params[:name]
      user.mobile_number = params[:mobile_number]
      user.residency_type = params[:residency_type]
      user.empl_type = params[:empl_type]
      user.loan_amount = params[:loan_amount]
      user.loan_tenure = params[:loan_tenure]
      user.save if user.changed?
      user
    end

    def get_user(id)
      where(id: id).first
    end
  end
end
