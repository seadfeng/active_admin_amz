Rails.application.routes.draw do
  mount Amz::Core::Engine => "/"
end
