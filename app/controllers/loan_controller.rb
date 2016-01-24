class LoanController < ApplicationController

  def new
  end

  def loan_enquiry
    #validates params
    @errors = {}
    if request.xhr?
      user = User.get_user(params[:user_id])
      params.merge!(residency_type: user[:residency_type],empl_type: user[:empl_type])
    else
      user = User.create_user_entry(params)
      unless user.valid?
        @errors= user.errors.messages
        render :new and return
      end
    end
    @bank_info = Bank.get_loan_enquiry_result(params)
    @bank_info[:user_id] = user.id

  end
end
