require "sinatra"
require "better_errors"
require 'bundler'
Bundler.require
# require 'rack'
# require 'rack/contrib'
# require './config/environments' #database configuration
# require './messages/message'    #Message class
require './room/RoomCluster'

# get '/index' do
# 	erb :index
# end

post '/room' do
	f = File.open("log.txt","w")
	params = JSON.parse(request.body.read)
	f.write(params)
	f.close
	url = params["room"]["url"]
	sofa = params["room"]["sofa"]
	loveseat = params["room"]["loveseat"]
	storage = params["room"]["storage"]
	footstool = params["room"]["footstool"]
	@message = RoomCluster.new(url,sofa,footstool,loveseat,storage)
end

get '/room' do
	return nil
end

# get '/messages/:id' do
# 	content_type :json
# 	@message = Message.find_by_id(params[:id].to_i)
#
# 	if @message
# 		@message.to_json
# 	else
# 		halt 404
# 	end
# end
