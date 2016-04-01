require 'rubygems'
require 'sinatra'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end

  def logged_in?
    session[:identity] ? true : false
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  if !session[:identity]
    erb 'Can you handle a <a href="/login/form">sign in</a>?'
  else
    @username = session[:identity]
    erb "Hello <%=@username%>!"
  end
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  @username = params[:username]
  @password = params[:password]
  if @username == "admin" && @password == "secret"
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    @error = 'Sorry, your login or password are incorrect'
    halt erb(:login_form)
  end
end

get '/logout' do
  session.delete(:identity)
  redirect to "/"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end