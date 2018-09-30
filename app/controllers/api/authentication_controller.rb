class Api::AuthenticationController < ActionController::API
  include AbstractController::Translation

  # api :POST, '/user_access_token', 'Get user access token'
  # description 'Returns user access token and refresh tokens'
  # param :client_id, String, desc: 'Client ID', required: true
  # param :client_secret, String, desc: 'Client secret', required: true
  # param :scopes, String, desc: 'Space-delimited list of requested scopes. Default scope is API'
  # param :username, String, desc: 'Username of user', required: true
  # param :password, String, desc: 'Password of user', required: true
  def user_access_token
    client_id = params['client_id']
    client_secret = params['client_secret']
    # TODO - Implement scopes conditions
    scopes = params['scopes'].presence || Doorkeeper.configuration.default_scopes.to_s

    application = oauth_application(client_id, client_secret)

    if application.blank?
      render json: { error: t('api.authentication.invalid_client') }, status: :forbidden
      return
    end


    username = params['username']
    password = params['password']
    user = User.authenticate(username, password)

    if user.blank?
      render json: { error: t('api.authentication.invalid_user') }, status: :forbidden
      return
    end

    expires_in =  Doorkeeper.configuration.access_token_expires_in || 7200
    use_refresh_token = Doorkeeper.configuration.reuse_access_token

    requested_scopes = scopes.split(' ').compact
    valid_scopes = (requested_scopes & application.scopes.to_a).join(' ')

    # TODO - use refresh token not working, creating new token every time. Need to fix that
    token = Doorkeeper::AccessToken.find_or_create_for(application, user.id, valid_scopes, expires_in, use_refresh_token)

    render json: token_as_json(token), status: :ok
  end

  # api :POST, '/oauth/token', 'Get client authentication token', url: '/'
  # description 'Return client authentication token'
  # param :client_id, String, desc: 'Client ID', required: true
  # param :client_secret, String, desc: 'Client secret', required: true
  # param :scopes, String, desc: 'Space-delimited list of requested scopes'

  # api :POST, '/forgot_password', 'Forgot Password'
  # description 'Get forgot password mail to the respective email'
  # param  :email, String, desc: 'Email ID', required: true
  # def forgot_password
  #   email = params[:email].strip
  #   if email.present?
  #     user = User.where(email: email).first
  #     if user.present?
  #       user.send_user_reset_password_instruction
  #     else
  #       render json: { error: "User not found" }, status: :unprocessable_entity
  #     end
  #   else
  #     render json: { error: "Please provide valid email" }, status: :unprocessable_entity
  #   end
  # end

  private

  def oauth_application(client_id, client_secret)
    # TODO - Add indexes for uid and secret
    @oauth_application ||= Doorkeeper::Application.where(uid: client_id, secret: client_secret).first
  end

  def token_as_json(token)
    {
      access_token: token.token,
      token_type: "bearer",
      expires_in: token.expires_in,
      refresh_token: token.refresh_token,
      created_at: token.created_at.to_i,
      scopes: token.scopes
    }
  end
end
