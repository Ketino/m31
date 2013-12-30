M31::Application.routes.draw do
  devise_for :users
  root :to =>  "audiofiles#index"
  get "friendship/search" => "friendship#search"
  get "audiofiles/download/:id" => "audiofiles#download", :as => "download"
  resources :audiofiles
  resources :friendship
end
