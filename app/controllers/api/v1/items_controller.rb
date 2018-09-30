class Api::V1::ItemsController < API::ApplicationController
  before_action :doorkeeper_authorize

  def index
    data = {
      items: {
        item1: {
          name: 'Item1'
        },
        item2: {
          name: 'Item2'
        },
        item3: {
          name: 'Item2'
        }
      }
    }

    render json: data, status: :ok
  end
end