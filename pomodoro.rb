# pomodoro.rb
require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubi"
require "redcarpet"
require "yaml"
require "bcrypt"
require 'date'


configure do 
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

helpers do
  def current_user
    user_info[session[:username]]
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer,
      tables: true,            # ← enable pipe-table parsing
      fenced_code_blocks: true # ← optional, but usually nice to have
    )
    markdown.render(text)
  end
end

def user_info
  YAML.load_file(users_file_path)
end

def write_user_info(users)
  File.write(users_file_path, users.to_yaml)
end

def users_file_path
  if ENV["RACK_ENV"] == 'test'
    File.expand_path('../test/users.yml', __FILE__)
  else
    File.expand_path('../users.yml', __FILE__)
  end
end

def valid_credentials?(username, password)
  credentials = user_info

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username][:hashed_password])
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
  if session[:last_done]
    @done = session.delete(:last_done)
    start_time = @done.delete(:start_time)
    end_time = @done.delete(:end_time)
    @done[:time] = end_time - start_time
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
  hashed_password = BCrypt::Password.create(password).to_s

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
post "/login" do
  username = params[:username]
  password = params[:password]

  if valid_credentials?(username, password)
    session[:message] = 'Welcome!'
    session[:username] = username
    redirect "/"
  else
    session[:message] = "Wrong Username and/or Password."
    redirect "/login"
  end

  erb :login
end

get "/login" do

  erb :login
end

get "/logout" do
  session[:message] = "See you soon, #{session[:username]}!"
  session.delete(:username)
  redirect "/login"
end

post '/timer/start' do # needed help with this AJAX request.
  now = Time.now
  session[:pending] = {
    task:       current_user[:task].last,
    start_time: now,
    # store YYYY-MM-DD as a String so it serializes & inspects cleanly
    start_date: now.strftime("%Y-%m-%d")
  }
  status 204
end

post '/timer/stop' do # needed help with this AJAX request.
  pending = session.delete(:pending) or halt 400, "No timer running"
  record  = pending.merge(end_time: Time.now)
  (session[:records] ||= []) << record

  # stash it for your next GET /
  session[:last_done] = record

  # just tell the client “OK” so JS can reload
  status 204
end
