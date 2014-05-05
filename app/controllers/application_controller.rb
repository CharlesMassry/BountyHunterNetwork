class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  private
  	def render_permission_error
  		render file: 'public/permission_error', status: :error, layout: false
  	end

  	def render_404
  		render file: 'public/404', status: :not_found, layout: false
  	end
end
