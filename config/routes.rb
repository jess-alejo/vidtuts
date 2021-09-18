Rails.application.routes.draw do
  devise_for :users

  resources :lessons
  resources :enrollments do
    collection do
      get :students
    end
  end

  namespace :analytics do
    get :users_per_day
    get :enrollments_per_day
    get :course_popularity
    get :money_makers
  end

  resources :courses do
    collection do
      get :enrolled
      get :pending_review
      get :authored
      get :pending_approval
    end
    member do
      patch :publish
      patch :review
      patch :approve
      get :analytics
    end
    resources :lessons do
      put :sort
      member do
        delete :remove_video
        delete :remove_video_thumbnail
      end
    end
    resources :enrollments, only: %i[new create]
  end

  resources :users, only: %i[index show edit update]
  resources :youtube, only: :show

  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'home/index'
  get 'activity', to: 'home#activity'
  get 'analytics', to: 'home#analytics'

  root 'home#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
