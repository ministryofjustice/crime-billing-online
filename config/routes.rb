Rails.application.routes.draw do

  root to: 'high_voltage/pages#show', id: 'home'

  namespace :api, format: :json do
    namespace :advocates do
      resources :claims
    end
  end

  devise_for :users

  resources :documents do
    get 'download', on: :member
  end

  resources :representation_orders do
    get 'download', on: :member
  end

  resources :messages, only: [:create]
  resources :user_message_statuses, only: [:index, :update]

  namespace :advocates do
    root to: 'claims#index'

    get 'landing', to: 'claims#landing'

    resources :claims do
      get 'confirmation', on: :member
      get 'outstanding', on: :collection
      get 'authorised', on: :collection
    end

    namespace :admin do
      root to: 'claims#index'

      resources :advocates
    end
  end

  namespace :case_workers do
    root to: 'claims#index'

    resources :claims, only: [:index, :show, :update]

    namespace :admin do
      root to: 'case_workers#index'

      resources :case_workers do
        get 'allocate', on: :member
      end
    end
  end
end
