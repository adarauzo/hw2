# In this assignment, you'll be using the domain model from hw1 (found in the hw1-solution.sql file)
# to create the database structure for "KMDB" (the Kellogg Movie Database).
# The end product will be a report that prints the movies and the top-billed
# cast for each movie in the database.

# To run this file, run the following command at your terminal prompt:
# `rails runner kmdb.rb`

# Requirements/assumptions
#
# - There will only be three movies in the database – the three films
#   that make up Christopher Nolan's Batman trilogy.
# - Movie data includes the movie title, year released, MPAA rating,
#   and studio.
# - There are many studios, and each studio produces many movies, but
#   a movie belongs to a single studio.
# - An actor can be in multiple movies.
# - Everything you need to do in this assignment is marked with TODO!

# Rubric
# 
# There are three deliverables for this assignment, all delivered within
# this repository and submitted via GitHub and Canvas:
# - Generate the models and migration files to match the domain model from hw1.
#   Table and columns should match the domain model. Execute the migration
#   files to create the tables in the database. (5 points)
# - Insert the "Batman" sample data using ruby code. Do not use hard-coded ids.
#   Delete any existing data beforehand so that each run of this script does not
#   create duplicate data. (5 points)
# - Query the data and loop through the results to display output similar to the
#   sample "report" below. (10 points)

# Submission
# 
# - "Use this template" to create a brand-new "hw2" repository in your
#   personal GitHub account, e.g. https://github.com/<USERNAME>/hw2
# - Do the assignment, committing and syncing often
# - When done, commit and sync a final time before submitting the GitHub
#   URL for the finished "hw2" repository as the "Website URL" for the 
#   Homework 2 assignment in Canvas

# Successful sample output is as shown:

# Movies
# ======

# Batman Begins          2005           PG-13  Warner Bros.
# The Dark Knight        2008           PG-13  Warner Bros.
# The Dark Knight Rises  2012           PG-13  Warner Bros.

# Top Cast
# ========

# Batman Begins          Christian Bale        Bruce Wayne
# Batman Begins          Michael Caine         Alfred
# Batman Begins          Liam Neeson           Ra's Al Ghul
# Batman Begins          Katie Holmes          Rachel Dawes
# Batman Begins          Gary Oldman           Commissioner Gordon
# The Dark Knight        Christian Bale        Bruce Wayne
# The Dark Knight        Heath Ledger          Joker
# The Dark Knight        Aaron Eckhart         Harvey Dent
# The Dark Knight        Michael Caine         Alfred
# The Dark Knight        Maggie Gyllenhaal     Rachel Dawes
# The Dark Knight Rises  Christian Bale        Bruce Wayne
# The Dark Knight Rises  Gary Oldman           Commissioner Gordon
# The Dark Knight Rises  Tom Hardy             Bane
# The Dark Knight Rises  Joseph Gordon-Levitt  John Blake
# The Dark Knight Rises  Anne Hathaway         Selina Kyle

# Delete existing data, so you'll start fresh each time this script is run.
# Use `Model.destroy_all` code.

Studio.destroy_all
Movie.destroy_all
Actor.destroy_all
Role.destroy_all

# Generate models and tables, according to the domain model.

rails generate model Studio name:text
rails generate model Movie title:text year_released:integer rated:text studio:references
rails generate model Actor name:text
rails generate model Role movie:references actor:references character_name:text

rails db:migrate

# app/models/studio.rb
class Studio < ApplicationRecord
  has_many :movies 
end

# app/models/movie.rb
class Movie < ApplicationRecord
  belongs_to :studio
  has_many :roles
end

# app/models/actor.rb
class Actor < ApplicationRecord
  has_many :roles
end

# app/models/role.rb
class Role < ApplicationRecord
  belongs_to :movie
  belongs_to :actor
end


# Insert data into the database that reflects the sample data shown above.
# Do not use hard-coded foreign key IDs.

# Create the studio
studio = Studio.create(name: "Warner Bros.")

# Create movies with associated studio
movies = [
  { title: "Batman Begins", year_released: 2005, rated: "PG-13", studio: studio },
  { title: "The Dark Knight", year_released: 2008, rated: "PG-13", studio: studio },
  { title: "The Dark Knight Rises", year_released: 2012, rated: "PG-13", studio: studio }
]
Movie.create(movies)

# Create actors & roles (Batman Begins)
batman_begins = Movie.find_by(title: "Batman Begins")
batman_begins.roles.create([
  { actor: Actor.create(name: "Christian Bale"), character_name: "Bruce Wayne" },
  { actor: Actor.create(name: "Michael Caine"), character_name: "Alfred" },
  { actor: Actor.create(name: "Liam Neeson"), character_name: "Ra's Al Ghul" },
  { actor: Actor.create(name: "Katie Holmes"), character_name: "Rachel Dawes" },
  { actor: Actor.create(name: "Gary Oldman"), character_name: "Commissioner Gordon" }
])

# Create actors & roles (The Dark Knight)
the_dark_knight = Movie.find_by(title: "The Dark Knight")
the_dark_knight.roles.create([
  { actor: Actor.create(name: "Christian Bale"), character_name: "Bruce Wayne" },
  { actor: Actor.create(name: "Heath Ledger"), character_name: "Joker" },
  { actor: Actor.create(name: "Aaron Eckhart"), character_name: "Harvey Dent" },
  { actor: Actor.create(name: "Michael Caine"), character_name: "Alfred" },
  { actor: Actor.create(name: "Maggie Gyllenhaal"), character_name: "Rachel Dawes" } 
])

# Create actors & roles (The Dark Knight Rises)
the_dark_knight_rises = Movie.find_by(title: "The Dark Knight Rises")
the_dark_knight_rises.roles.create([
  { actor: Actor.create(name: "Christian Bale"), character_name: "Bruce Wayne" },
  { actor: Actor.create(name: "Gary Oldman"), character_name: "Commissioner Gordon" },
  { actor: Actor.create(name: "Tom Hardy"), character_name: "Bane" },
  { actor: Actor.create(name: "Joseph Gordon-Levitt"), character_name: "John Blake" },
  { actor: Actor.create(name: "Anne Hathaway"), character_name: "Selina Kyle" } 
])

# Prints a header for the movies output
puts "Movies"
puts "======"
puts ""

# Query the movies data and loop through the results to display the movies output.

# app/controllers/movies_controller.rb
def index
  @movies = Movie.all  # Fetch all movies
end

# app/views/movies/index.html.erb
<h1>All Movies</h1>

<ul>
  <% @movies.each do |movie| %>
    <li>
      <%= movie.title %> (<%= movie.year_released %>) - <%= movie.rated %>
    </li>
  <% end %>
</ul>

# Prints a header for the cast output
puts ""
puts "Top Cast"
puts "========"
puts ""

# Query the cast data and loop through the results to display the cast output for each movie.

# app/views/movies/index.html.erb
<h1>All Movies</h1>

<ul>
  <% @movies.each do |movie| %>
    <li>
      <h2><%= movie.title %> (<%= movie.year_released %>) - <%= movie.rated %></h2>

      <h3>Cast</h3>
      <ul>
        <% movie.actors.uniq.each do |actor| %> <%# Get unique actors %>
          <li><%= actor.name %></li>
        <% end %>
      </ul>
    </li>
  <% end %>
</ul>