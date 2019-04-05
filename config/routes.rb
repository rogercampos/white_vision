WhiteVision::Engine.routes.draw do
  root to: "application#home"

  post '/sendgrid-event-callback', to: 'sendgrid_event_callback#callback', as: :sendgrid_callback, format: :json

  resources :previews, only: :show
  resources :email_templates, only: [:create, :update, :edit] do
    get :preview, on: :member
    post :deliver_preview, on: :member
  end

end
