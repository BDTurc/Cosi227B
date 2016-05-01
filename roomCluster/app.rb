require "sinatra"
require "better_errors"
require 'bundler'
require 'json'
Bundler.require
Dir[File.dirname(__FILE__) + '/room/*.rb'].each {|file| require file }

post '/room' do
	params = JSON.parse(request.body.read)
	url = params["room"]["url"]
	sofa = params["room"]["sofa"]
	loveseat = params["room"]["loveseat"]
	storage = params["room"]["storage"]
	footstool = params["room"]["footstool"]
	RoomCluster.new(url,sofa,footstool,loveseat,storage)
	Ranker.new(url)
end

get '/room' do
	room = File.read("room.json")
	sofa_rank = File.read("sofa.json")
	loveseat_rank = File.read("loveseat.json")
	storage_rank = File.read("storage.json")
	footstool_rank = File.read("foot.json")
	# results = { "room" => room,
	# 						"sofa" => sofa_rank,
	# 						"loveseat" => loveseat_rank,
	# 						"storage" => storage_rank,
	# 						"footstool" => footstool_rank }
	results = { "room" => JSON.parse(room),
							"sofa" => JSON.parse(sofa_rank),
							"loveseat" => JSON.parse(loveseat_rank),
							"storage" => JSON.parse(storage_rank),
							"footstool" => JSON.parse(footstool_rank) }

	return results.to_json
end
