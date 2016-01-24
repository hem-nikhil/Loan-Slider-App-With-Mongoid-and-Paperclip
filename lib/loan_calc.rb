class LoanCalc

  attr_accessor :loan_tenure,:loan_amount

  def initialize(params)
    @loan_amount = params[:loan_amount].to_f
    @loan_tenure = params[:loan_tenure].to_i
  end

  def get_upper_and_lower_bounds
    result = { upper_amount:GlobalConstant::LOAN_AMOUNT[:initial_upper_amount],
               lower_amount:GlobalConstant::LOAN_AMOUNT[:initial_lower_amount],
               current_amount: loan_amount,
               upper_tenure:GlobalConstant::LOAN_TENURE[:upper_tenure],
               lower_tenure:GlobalConstant::LOAN_TENURE[:lower_tenure],
                current_tenure: loan_tenure}

    while loan_amount > result[:upper_amount] && loan_amount < GlobalConstant::LOAN_AMOUNT[:max_upper_amount]
      result[:upper_amount] = result[:upper_amount] << 1
    end
    if loan_amount > GlobalConstant::LOAN_AMOUNT[:max_upper_amount] || result[:upper_amount] > GlobalConstant::LOAN_AMOUNT[:max_upper_amount]
      result[:upper_amount] = GlobalConstant::LOAN_AMOUNT[:max_upper_amount]
    end

    upper_amount_msg  = get_bounds_in_words(result[:upper_amount])
    result[:upper_amount_msg] = upper_amount_msg
    result[:lower_amount_msg] = "0"
    result[:upper_tenure_msg] = "#{result[:upper_tenure]} Years"
    result[:lower_tenure_msg] = "1 Year"
    result
  end


  def calculate_monthly_emi(rate_of_intrest)
    rate_of_intrest = rate_of_intrest.to_f
    loan_tenure_in_months = loan_tenure * 12
    return nil if loan_tenure_in_months <= 0
    principal_amount,number_of_months = loan_amount,loan_tenure_in_months
    roi_per_month = rate_of_intrest.to_f/(12*100)
    temp = (1+roi_per_month)**number_of_months
    emi = principal_amount * roi_per_month * (temp/(temp-1))
    emi
  end

  def validate_loan_range
    error_messages = []
    if loan_amount > GlobalConstant::LOAN_AMOUNT[:max_upper_amount] || loan_amount < GlobalConstant::LOAN_AMOUNT[:min_lower_amount]
      error_messages << "Loan Amount Should be Between #{GlobalConstant::LOAN_AMOUNT[:min_lower_amount]} and #{GlobalConstant::LOAN_AMOUNT[:max_upper_amount]}"
    end
    if loan_tenure > GlobalConstant::LOAN_TENURE[:upper_tenure] || loan_tenure < GlobalConstant::LOAN_TENURE[:lower_tenure]
      error_messages << "Loan Tenure Should be Between #{GlobalConstant::LOAN_TENURE[:upper_tenure]} and #{GlobalConstant::LOAN_TENURE[:lower_tenure]}"
    end
    error_messages
  end
  def get_bounds_in_words(range)
    length = range.to_s.split("").count
    case length
      when 3
        value = range.to_f/10**2
        "#{value.to_f} Hundred"
      when 4..5
        value = range.to_f/10**3
        "#{value.to_f} Thousand"
      when 6..7
        value = range.to_f/10**5
        "#{value.to_f} Lakhs"
      when 8..10
        value = range.to_f/10**7
        "#{value.to_f} Crores"
      else
        "#{range.to_f}"
    end
  end
end