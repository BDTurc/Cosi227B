require_relative 'RoomCluster.rb'
class Extensible

	def initialize(comparable1, comparable2, numSofa, numFoot, numLove, numStorage)
		@initialRoom = RoomCluster.new(comparable1, numSofa, numFoot, numLove, numStorage)
		averageResults(comparable1, comparable2)
	end

	def averageResults(comparable1, comparable2)
		@initialRoom.buildUnknownRoom(comparable1, comparable2)
	end
end

Extensible.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5])