Rails.application.routes.draw do
  resources :wizard_forms, only: %i[index new create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'wizard_forms/flush', to: 'wizard_forms#flush'
  get 'img', to: 'tracking#img'
  get 'm', to: 'tracking#redirector'
end
