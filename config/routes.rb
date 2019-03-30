WhiteVision::Engine.routes.draw do
  root to: "application#home"

  post '/sendgrid-event-callback', to: 'sendgrid_event_callback#callback', as: :sendgrid_callback, format: :json
end
