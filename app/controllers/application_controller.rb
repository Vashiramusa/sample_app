class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def hello
    render html: "Greetings from Vashira Musa Samaila!"
  end
end
