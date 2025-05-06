require 'sinatra/base'
require 'json'

class MovieApp < Sinatra::Base
  @@movies = {}
  @@current_id = 1

  #Ver todas las peliculas
  #curl -v http://localhost:4567/movies
  get '/movies' do
    content_type :json
    [200, { "Content-Type" => "application/json" }, [@@movies.values.to_json]]
  end


  # Ver una peliculas por ID
  #curl -v http://localhost:4567/movies/1
  get '/movies/:id' do
    content_type :json
    movie = @@movies[params[:id].to_i]

    if movie
      [200, { "Content-Type" => "application/json" }, [movie.to_json]]
    else
      status 404
      [404, { "Content-Type" => "application/json" }, [{ error: "Movie not found" }.to_json]]
    end
  end


  # Agregar una nueva película
  #curl -v -X POST http://localhost:4567/movies -H "Content-Type: application/json" -d '{"title":"Inception", "year":2010, "type":"science fiction"}'
  #curl -v -X POST http://localhost:4567/movies -H "Content-Type: application/json" -d '{"title":"Nemo", "year":2003, "type":"animation"}'

  post '/movies' do
    content_type :json
    data = JSON.parse(request.body.read)

    new_movie = {
      id: @@current_id,
      title: data['title'],
      year: data['year'],
      type: data['type']
    }

    @@movies[@@current_id] = new_movie
    @@current_id += 1

    [201, { "Content-Type" => "application/json" }, [
    { message: "Movie '#{new_movie[:title]}' added successfully." }.to_json
  ]]
  end


  # Actualizar una película existente
  #curl -v -X PUT http://localhost:4567/movies/1 -H "Content-Type: application/json" -d '{"title":"Nonexistent Movie", "year":2022, "type":"fantasy"}'
  put '/movies/:id' do
    content_type :json
    id = params[:id].to_i
    movie = @@movies[id]

    if movie
      data = JSON.parse(request.body.read)
      movie[:title] = data['title'] if data['title']
      movie[:year] = data['year'] if data['year']
      movie[:type] = data['type'] if data['type']

      @@movies[id] = movie

      [200, { "Content-Type" => "application/json" }, [
        { message: "Movie '#{movie[:title]}' updated successfully." }.to_json
      ]]
    else
      [404, { "Content-Type" => "application/json" }, [
        { error: "Movie not found" }.to_json
      ]]
    end
  end


  # Eliminar una película por ID
  #curl -v -X DELETE http://localhost:4567/movies/1
  delete '/movies/:id' do
    content_type :json
    id = params[:id].to_i

    if @@movies.delete(id)
      [200, { "Content-Type" => "application/json" }, [
        { message: "Movie with ID #{id} deleted successfully." }.to_json
      ]]
    else
      [404, { "Content-Type" => "application/json" }, [
        { error: "Movie not found" }.to_json
      ]]
    end
  end
end

MovieApp.run! if __FILE__ == $0
