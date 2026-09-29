Rails.application.routes.draw do
  root 'joins#new'

  devise_for :users, only: %i[sessions invitations], controllers: { invitations: 'users/invitations' }

  resource :join, only: %i[new create]
  get 'how-to-play', to: 'pages#how_to_play', as: :how_to_play
  get 'rules', to: 'pages#rules', as: :rules

  # The phone screen. Every route here acts on the player remembered by this phone's cookie.
  resource :play, only: :show, controller: 'devices' do
    resource :avatar, only: %i[edit update], module: :players
    resources :players, only: %i[new create], module: :devices
    resources :reveals, only: %i[show update], param: :seat_id
    resources :ballots, only: %i[create destroy]
  end

  namespace :host do
    resources :games, only: %i[index new create show] do
      scope module: :games do
        resource :launch, only: :create
        resources :rounds, only: :create
        resource :rotation, only: :create
        resource :ballot_box, only: %i[create destroy]
        resource :finish, only: :create
        resource :deletion, only: %i[new create]
      end
    end
    resources :players, only: [] do
      scope module: :players do
        resource :backup, only: %i[create destroy]
        resource :removal, only: %i[new create]
      end
    end
  end

  namespace :admin do
    resources :users, only: %i[index show new create edit update] do
      resource :setup_link, only: :create, module: :users
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
end
