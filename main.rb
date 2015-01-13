require 'sinatra'
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'
require_relative 'secret_email_info.rb'
require './sinatra/auth'


class Test < Sinatra::Application
  
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

    def send_message
      Pony.mail({
       :from => params[:name] + "<" + params[:email] + ">",
       :to => $email,
       :subject => params[:name] + " has contacted you",
       :body => params[:message],
       :via => :smtp,
       :via_options => {
         :address              => 'smtp.gmail.com',
         :port                 => '587',
         :enable_starttls_auto => true,
         :user_name            => $email,
         :password             => $password,
         :authentication       => :plain,
         :domain => 'localhost.localdomain'
        }
       })
    end
  end
  
  before do
    set_title
  end

  configure do
    enable :sessions
  end

  configure :development do
    DataMapper.setup(:default, "postgres://localhost/songs_development")
     set :email_address => $email,
     :email_user_name => $email,
     :email_passwod => $password,
     :email_domain => 'localhost.localdomain'
  end

  configure :production do
    DataMapper.setup(:default, ENV['DATABASE_URL'])
    set :email_address => $email,
    :email_user_name => $email,
    :email_passwod => $password,
    :email_domain => 'localhost.localdomain'
  end

  DataMapper.finalize
  DataMapper.auto_upgrade!
  
  get('/styles.css'){ scss :styles }

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

  post '/contact' do
    send_message
    flash[:notice] = "Thank you for your message. We'll be in touch soon."
    redirect to('/')
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
 
end

