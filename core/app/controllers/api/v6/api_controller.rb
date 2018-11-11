class Api::V6::ApiController < ApplicationController
  include Graphiti::Rails
  include Graphiti::Responders

  register_exception Graphiti::Errors::RecordNotFound,
    status: 404

  rescue_from Exception do |e|
    handle_exception(e, show_raw_error: Rails.env.development?)
  end

  def allow_graphiti_debug_json?
    Rails.env.development?
  end

  # self.page_cache_directory = Rails.public_path
  self.perform_caching = true
  self.cache_store = :redis_store, 'redis://redis:6379/0/cache'
end
