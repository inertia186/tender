require 'pagy'
require 'pagy/extras/array'
require 'pagy/extras/metadata'
require 'pagy/extras/bootstrap'
require 'pagy/extras/countless'
require 'pagy/extras/overflow'

Rails.application.config.assets.paths << Pagy.root.join('javascripts')

Pagy::VARS[:items] = 100
Pagy::VARS[:overflow] = :empty_page
