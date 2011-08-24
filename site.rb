require "rubygems"
require "bundler/setup"
Bundler.require(:default)

class Site < Sinatra::Application
  set :server, %w[thin]
  set :environment, :development 
  set :views, File.dirname(__FILE__) + "/themes"
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :haml, {:ugly=>true} 
  
  get "/player.js" do
    CoffeeScript.compile File.read("Source/Moosic.coffee")
  end
  
  get "/theme.css" do
    sass :"default/theme"
  end
  
  get "/" do
    haml :index
  end
  
  get "/songs/:song" do
    content_type 'audio/mpeg'
    send_file "songs/#{params[:song]}"
  end
end
