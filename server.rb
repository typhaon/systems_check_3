require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipe_box')

    yield(connection)

  ensure
    connection.close
  end
end



get '/recipes'  do

query = "SELECT name, id FROM recipes ORDER BY name"

@results = db_connection do |conn|
  conn.exec(query)
end

erb :'recipes/index'

end


get '/recipes/:id' do

ident = params[:id]

query = "SELECT recipes.instructions, ingredients.name AS ingredients
        FROM recipes
        JOIN ingredients ON ingredients.recipe_id = recipes.id
        WHERE recipes.id = #{ident}"

recipe_results_query = "SELECT recipes.name, recipes.description, recipes.instructions
                        FROM recipes
                        WHERE recipes.id = #{ident}"

@results = db_connection do |conn|
  conn.exec(query)
end

@recipe_results = db_connection do |conn|
  conn.exec(recipe_results_query)[0]
end

erb :'recipes/show'
end
