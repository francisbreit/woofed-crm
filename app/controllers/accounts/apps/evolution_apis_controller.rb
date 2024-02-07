class Accounts::Apps::EvolutionApisController < InternalController
  before_action :set_evolution_api, only: %i[edit update refresh_qr_code pair_qr_code]

  def new
    @evolution_api = Apps::EvolutionApi.new
  end

  def create
    result = Accounts::Apps::EvolutionApis::Create.call(current_user, evolution_api_params)
    @evolution_api = result[result.keys.first]
    if result.key?(:ok)
      redirect_to pair_qr_code_account_apps_evolution_api_path(current_user.account, @evolution_api.id)
    else
      @evolution_api = result[:error]
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @evolution_apis = current_user.account.apps_evolution_apis.order(updated_at: :desc)
    @pagy, @evolution_apis = pagy(@evolution_apis)
  end

  def edit; end

  def update
    if @evolution_api.update(evolution_api_params)
      flash[:notice] = 'Whatsapp updated successfully!'
      redirect_to edit_account_apps_evolution_api_path(current_user.account, @evolution_api)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def refresh_qr_code
    Accounts::Apps::EvolutionApis::Instance::Create.call(@evolution_api)
  end

  def pair_qr_code; end

  private

  def set_evolution_api
    @evolution_api = current_user.account.apps_evolution_apis.find(params[:id])
  end

  def evolution_api_params
    params.require(:apps_evolution_api).permit(:name)
  end
end
