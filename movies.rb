require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  #Add code here
  erb :index
end


# Add code here

get '/movies/new' do
  erb :new
end

# get '/movies' do
#   "sdf"
# end

post '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  c.exec_params("INSERT INTO movies (title, year, description, rating) VALUES ($1, $2, $3, $4)",
                  [params["title"], params["year"], params["description"], params["rating"]])
  c.close
  # binding.pry
  # @title = params["title"]
  # @year = params["year"]
  # @description = params["description"]
  # @rating = params["rating"]
  # binding.pry
  # redirect '/confirmation'
  # TODO: create redirecting page - the global variables are not stored
  redirect '/'
end



get '/results' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  @results = c.exec_params("SELECT * FROM movies WHERE title = $1;", [params["title"]])  
  c.close
  # binding.pry
  # @results.inspect
  # TODO: why @results.inspect is not returning anything meeaningfull yet works in erb :results
  erb :results
end


get '/movie_detail/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  @movie_detail = c.exec_params("SELECT * FROM movies WHERE id = $1;", [params[:id]])  
  c.close
  @movie_detail.inspect
  # binding.pry
  erb :movie_detail
end

# <!-- <%= @movie_detail["title"] %> <%=@movie_detail["year"] -->


get '/confirmation' do 
    erb :confirmation
end



def dbname
  "testdb"
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movies;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

# binding.pry