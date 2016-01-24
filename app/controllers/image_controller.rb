class ImageController < ApplicationController
  def new
  end

  def show
    @id = params[:id]
    @image = BankLogo.find(@id)
  end
  def create
    @image = BankLogo.new(image_params)
    # @image[:logo]=params[:image][:logo]
    # @image[:bank_name]=params[:image][:bank_name]
    if @image.save
      redirect_to :action => :show, :id => @image.id
    end
  end

  private
  def image_params
    params.require(:bank_logo).permit(:logo, :bank_name )
  end
end
