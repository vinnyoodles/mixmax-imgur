require 'uri'
require 'net/http'
require 'net/https'
class ApiController < ApplicationController
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  # regex
  # imgur.com\/?(gallery)?\/[^\/]+$
  def resolver
    return if params[:url].nil?
    uri = URI::parse(params[:url])
    uri = URI::parse("https://#{params[:url]}") if uri.scheme.nil?

    headers      = { "Authorization" => "Client-ID 591ab9f4d9c3aad"   }
    path         = "/3/gallery/image#{uri.path}.json"

    uri          = URI("https://api.imgur.com#{path}")
    request, _   = Net::HTTP::Get.new(path, headers)
    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response     = http.request(request)
    payload      = JSON.parse(response.body)

    link = payload["data"]["link"]
    render :json => { :body => "<img style=\"max-width:100%;\" src=\"#{link}\" width=300/>".html_safe }
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'https://compose.mixmax.com'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = 'https://compose.mixmax.com'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
end
