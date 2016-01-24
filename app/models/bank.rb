class Bank
  include Mongoid::Document
  field :bank_name, type: String
  field :processing_type, type: String
  field :processing_amount, type: Float
  field :rate_type, type: String
  field :rate, type: Float
  field :loan_min_vl, type: Float
  field :loan_max_vl, type: Float
  field :loan_tenure, type: Integer
  field :residency_type, type: Array
  field :empl_type, type: Array
  field :status, type: Integer

  store_in collection: "pricing_cms"

  scope :of_residency_type, ->(residency_type) { where(residency_type: residency_type ) }
  scope :of_empl_type, ->(empl_type) { where(empl_type: empl_type ) }
  scope :in_loan_amount_range, ->(loan_amount) { where({loan_min_vl:{"$lte" => loan_amount}, loan_max_vl:{"$gte" => loan_amount}} ) }
  scope :in_loan_tenure, ->(loan_tenure) { where(loan_tenure: {"$gte" => loan_tenure}) }
  scope :active_status, -> {where(status: 1)}

  class << self
    def get_loan_enquiry_result(params)
      loan_calculator = LoanCalc.new({loan_amount:params[:loan_amount],loan_tenure: params[:loan_tenure]})
      error_messages = loan_calculator.validate_loan_range
      bounds_for_amount_and_tenure = loan_calculator.get_upper_and_lower_bounds
      matched_loan_bank_details = active_status.of_residency_type(params[:residency_type]).of_empl_type(params[:empl_type]).in_loan_amount_range(params[:loan_amount].to_f).in_loan_tenure(params[:loan_tenure].to_i).asc(:bank_name)
      bank_names = matched_loan_bank_details.pluck(:bank_name)
      bank_images = BankLogo.get_bank_images(bank_names)
      bank_loan_details = get_emi_merged_with_bank_details(matched_loan_bank_details,loan_calculator,params[:loan_amount],bank_images)
      {
          limits: bounds_for_amount_and_tenure,
          bank_loan_details: bank_loan_details,
          loan_amount:params[:loan_amount],
          loan_tenure: params[:loan_tenure],
          error_messages: error_messages
      }
    end

    def get_emi_merged_with_bank_details(matched_loan_bank_details,loan_calculator,loan_amount,bank_images)
      emi_merged_bank_details = []
      matched_loan_bank_details.each do |bank_details|
        result = {}
        result[:emi] = loan_calculator.calculate_monthly_emi(bank_details[:rate])
        result[:charges] = calculate_processing_amount(loan_amount,bank_details[:processing_amount],bank_details[:processing_type])
        result[:rate] = bank_details[:rate]
        result[:rate_type] = bank_details[:rate_type]
        result[:bank_name] = bank_details[:bank_name]
        result[:logo] = bank_images[bank_details[:bank_name]]
        emi_merged_bank_details << result
      end
      emi_merged_bank_details
    end

    def calculate_processing_amount(loan_amount,processing_amount,type)
      final_processing_amount = nil
      case type
        when "flat_fee"
          final_processing_amount = processing_amount.to_f
        when "dynamic"
          final_processing_amount = processing_amount[0].to_f * processing_amount[1].to_f
        when "percentage"
          final_processing_amount = loan_amount.to_f * processing_amount.to_f / 100
        else
          final_processing_amount = 0
      end
      final_processing_amount
    end
  end

end
