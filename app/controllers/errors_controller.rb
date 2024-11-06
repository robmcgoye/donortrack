class ErrorsController < ApplicationController
  def show
    @request_action ||= request.env["REQUEST_URI"]
    @error_code ||= request.env["REQUEST_STATUS_CODE"]
    @error_message ||= request.env["REQUEST_STATUS_MESSAGE"]
    render layout: "errors/application", template: "errors/show"
  end
  # def not_found
  #   @request_action = request.env["REQUEST_URI"]
  #   render template: "errors/not_found"
  # end

  # def unprocessable_entity
  #   @request_action = request.env["REQUEST_URI"]
  #   render template: "errors/unprocessable_entity"
  # end

  # def internal_server_error
  #   @request_action = request.env["REQUEST_URI"]
  #   render template: "errors/internal_server_error"
  # end
end
