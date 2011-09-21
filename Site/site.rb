require "rubygems"
require "bundler/setup"
Bundler.require(:default)

class Site < Sinatra::Application
  set :server, %w[thin]
  set :environment, :development 
  set :views, File.dirname(__FILE__) + "/views"
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :haml, {:ugly=>true} 
  
  get "/site.js" do
    CoffeeScript.compile File.read("views/site.coffee")
  end
  
  get "/theme.css" do
    sass :"theme"
  end
  
  get "/" do
    haml :index
  end
  
  get "/songs/:song" do
    content_type 'audio/mpeg'
    send_file "songs/#{params[:song]}"
  end
end
