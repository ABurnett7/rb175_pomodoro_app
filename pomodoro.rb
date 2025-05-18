# pomodoro.rb
require "sinatra"
require "sinatra/reloader"
require "tilt/erubi"
require "redcarpet"
require "yaml"
require "bcrypt"

configure do 
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

def user_info
  users = if ENV["RACK_ENV"] =='test'
    File.expand_path('../test/users.yml', __FILE__)
  else
    File.expand_path('../users.yml', __FILE__)
  end
  YAML.load_file(users)
end

def write_user_info(users)
  users_path = if ENV["RACK_ENV"] == 'test'
    File.expand_path('../test/users.yml', __FILE__)
  else
    File.expand_path('../users.yml', __FILE__)
  end

  File.write(users_path, users.to_yaml)
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

get "/" do
  unless session[:username]
    session[:message] = 'Log in to track your progress!'
    redirect "/login"
  end

  erb :index 
end

get "/register" do
  erb :register
end

post "/register" do
  users = user_info

  username = params[:new_username]

  password = params[:password]
  hashed_password = BCrypt::Password.create(password)

  task = params[:task].empty? ? 'My Task' : params[:task] 
  focus_time = params[:focus_time].empty? ? '25' : params[:focus_time]
  rest_time = params[:rest_time].empty? ? '5' : params[:rest_time]
  

  if users.keys.include?(username)
    session[:message] = "#{username} already in use. Please choose another username."
    redirect "/register"
  elsif username.nil? || username.empty? || password.nil? || password.empty?
    session[:message] = "Username and password are required."
    redirect "/register"
  else
    users[username] = {hashed_password: hashed_password, task: [task], focus_time: focus_time, rest_time: rest_time}
    session[:username] = username
    write_user_info(users)
    session[:message] = "Welcome #{username}!"
    redirect "/"  end
end
get "/login" do

  erb :login
end