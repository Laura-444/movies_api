require 'sinatra/base'
require 'json'

class MovieApp < Sinatra::Base
  @@movies = {}
  @@current_id = 1

  # Obtener todas las peliculas
  #curl -v http://localhost:4567/movies
  get '/movies' do
    # status 200
    # content_type :json
    # @@movies.values.to_json

    [200, { "Content-Type" => "application/json" }, [@@movies.values.to_json]]
  end


  # Obtener pelicula por ID
  #curl -v http://localhost:4567/movies/1
  get '/movies/:id' do
    movie = @@movies[params[:id].to_i]

    if movie
      [200, { "Content-Type" => "application/json" }, [movie.to_json]]
    else
      [404, { "Content-Type" => "application/json" }, [{ error: "Movie not found" }.to_json]]
    end
  end


  # Agregar una nueva película
  #curl -v -X POST http://localhost:4567/movies -H "Content-Type: application/json" -d '{"title":"Inception", "year":2010, "type":"science fiction"}'
  #curl -v -X POST http://localhost:4567/movies -H "Content-Type: application/json" -d '{"title":"Nemo", "year":2003, "type":"animation"}'
  post '/movies' do
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
    { message: "Movie '#{new_movie[:title]}' added successfully." }.to_json]]
  end


  # Actualizar una película por ID
  #curl -v -X PUT http://localhost:4567/movies/1 -H "Content-Type: application/json" -d '{"title":"Matrix", "year":1999, "type": "science fiction"}'
  put '/movies/:id' do
    id = params[:id].to_i
    movie = @@movies[id]

    if movie
      data = JSON.parse(request.body.read)

      if data['title']
        movie[:title] = data['title']
      end
      if data['year'] 
        movie[:year] = data['year']
      end
      if data['type'] 
        movie[:type] = data['type']
      end

      @@movies[id] = movie

      [200, { "Content-Type" => "application/json" }, [
        { message: "Movie '#{movie[:title]}' updated successfully." }.to_json]]
    else
      [404, { "Content-Type" => "application/json" }, [
        { error: "Movie not found" }.to_json]]
    end
  end


  # Eliminar una película por ID
  #curl -v -X DELETE http://localhost:4567/movies/1
  delete '/movies/:id' do
    id = params[:id].to_i
    movie = @@movies[id]

    if @@movies.delete(id)
      [200, { "Content-Type" => "application/json" }, [
        { message: "Movie '#{movie[:title]}' with 'ID #{id}', was deleted successfully." }.to_json]]
    else
      [404, { "Content-Type" => "application/json" }, [
        { error: "Movie not found" }.to_json]]
    end
  end
end

MovieApp.run! if __FILE__ == $0
