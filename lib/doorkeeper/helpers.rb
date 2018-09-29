module Doorkeeper
  module Rails
    module Helpers

      def doorkeeper_authorize(*scopes)
        return true if current_user.present? && scopes == Doorkeeper.configuration.default_scopes
        @_doorkeeper_scopes = scopes.presence || Doorkeeper.configuration.default_scopes
        token_valid = valid_doorkeeper_token?
        return doorkeeper_render_error unless token_valid

        return unless doorkeeper_token.resource_owner_id

        user = User.where(id: doorkeeper_token.resource_owner_id).first
        return render json: { status: :unauthorized }, status: :unauthorized unless user.active_for_authentication?

        sign_in user
        @current_user = warden.user
      end

      def sign_out_token_user
        if bearer_in_header && current_user
          reset_session
          sign_out current_user
        end
      end

      def bearer_in_header
        return false if request.env['HTTP_AUTHORIZATION'].nil?
        token = request.env['HTTP_AUTHORIZATION'].downcase
        token.include?('bearer')
      end
    end
  end
end
