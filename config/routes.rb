Rails.application.routes.draw do
  namespace :api do
    post 'signup', to: 'auth#signup'
    post 'login', to: 'auth#login'
    get 'current_user', to: 'users#current'
    resources :banners, only: [:index, :show, :create, :destroy, :update] do
      collection do
        get 'my_banners', to: 'banners#my_banners'
      end
    end
  end
end
