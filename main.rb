require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'

get('/styles.css'){ scss :styles }

configure do
 enable :sessions
 set :username, 'frank'
 set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  enable :sessions
end

configure :production do
 DataMapper.setup(:default, ENV['DATABASE_URL'])
end

before do
  set_title
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end


  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end
end

get '/' do
  slim :home
end

get '/about' do
  @title = "All About This Website"
  slim :about
end

get '/contact' do
  @title = "Contact information"
  slim :contact
end

not_found do
  slim :not_found
end

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    slim :login
 end
end

get '/logout' do
  session.clear
  redirect to ('/login')
end





