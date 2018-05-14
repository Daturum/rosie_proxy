Rails.application.routes.draw do
  mount Rosie::Engine => '/', as: 'rosie'
end
