class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  attr_reader :current_user

  protected

  def authenticate_request!
    # ここがfalse
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private

  # Barer tokenを返却するメソッド
  def http_token
      @http_token ||= if request.headers['Authorization'].present?
        request.headers['Authorization'].split(' ').last
      end
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  def user_id_in_token?
    # Bearer Tokenが存在していて、且つauth_tokenが存在していて、且つauth_token[:user_id].to_iが存在している場合true
    http_token && auth_token && auth_token[:user_id].to_i
  end
end
