require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './song'

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

get '/songs' do
  @songs = Song.all
  slim :songs
end

get '/songs/:id' do
  @song = Song.get(params[:id])
  slim :show_song
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





