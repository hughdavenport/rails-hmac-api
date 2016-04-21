class ApiKeysController < ApplicationController
  before_action :set_api_key, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  # GET /users/1/api_keys
  # GET /users/1/api_keys.json
  def index
    @api_keys = ApiKey.all
  end

  # GET /users/1/api_keys/1
  # GET /users/1/api_keys/1.json
  def show
  end

  # GET /users/1/api_keys/new
  def new
    @api_key = @user.api_keys.new
  end

  # GET /users/1/api_keys/1/edit
  def edit
  end

  # POST /users/1/api_keys
  # POST /users/1/api_keys.json
  def create
    @api_key = @user.api_keys.new(api_key_params)

    respond_to do |format|
      if @api_key.save
        format.html { redirect_to user_api_key_url(@user, @api_key), notice: 'Api key was successfully created.' }
        format.json { render :show, status: :created, location: @api_key }
      else
        format.html { render :new }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1/api_keys/1
  # PATCH/PUT /users/1/api_keys/1.json
  def update
    respond_to do |format|
      if @api_key.update(api_key_params)
        format.html { redirect_to user_api_key_url(@user, @api_key), notice: 'Api key was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_key }
      else
        format.html { render :edit }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1/api_keys/1
  # DELETE /users/1/api_keys/1.json
  def destroy
    @api_key.destroy
    respond_to do |format|
      format.html { redirect_to user_api_keys_url(@user), notice: 'Api key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_api_key
      @api_key = ApiKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_key_params
      params.require(:api_key).permit(:user_id, :public, :secret)
    end
end
