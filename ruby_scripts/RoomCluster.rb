class RoomCluster
	def initialize(item, numSofa, numFoot, numLove, numStorage)
		@numSofa = numSofa.to_i
		@numFoot = numFoot.to_i
		@numLove = numLove.to_i
		@numStorage = numStorage.to_i

		@types = Hash.new
		@typeLookup = Hash.new
		getTypes
		@mainHash = Hash.new
		@currentRoom = Array.new
		buildRoom(item)
	end

	def getTypes
		contents = File.open("classified.csv", "r")
		contents.each_line do | row |
			img, type = row.split(",")
			type = type.strip
			img = img.strip
			@typeLookup[img] = type

			if !@types.has_key? type
				array = Array.new
				array << img
				@types[type] = array
			else
				array = @types[type]
				array << img
				@types[type] = array
			end
		end
	end

	def buildRoom(item)
		results = File.open("../clustering/results")
		results.each_line do | row |
			content = row.split(",")
			mainPiece = content[2].strip
			compareOne = content[3].strip
			ansOne = content[4].strip
			compareTwo = content[6].strip
			ansTwo = content[7].strip
			compareThree = content[9].strip
			ansThree = content[10].strip

			if !@mainHash.has_key? mainPiece

				newHash = Hash.new
				oneArray = Array.new
				twoArray = Array.new
				threeArray = Array.new

				if ansOne == "Yes" 
					oneArray[0] = 1
				else
					oneArray[0] = 0
				end
				oneArray[1] = 1

				if ansTwo == "Yes" 
					twoArray[0] = 1
				else
					twoArray[0] = 0
				end
				twoArray[1] = 1

				if ansThree == "Yes" 
					threeArray[0] = 1
				else
					threeArray[0] = 0
				end
				threeArray[1] = 1

				newHash[compareOne] = oneArray
				newHash[compareTwo] = twoArray
				newHash[compareThree] = threeArray							
				@mainHash[mainPiece] = newHash
			else
				hash = @mainHash[mainPiece]
				if !hash.has_key? compareOne
					oneArray = Array.new
					if ansOne == "Yes" 
						oneArray[0] = 1
					else
						oneArray[0] = 0
					end
					oneArray[1] = 1
					hash[compareOne] = oneArray
				else
					array = hash[compareOne]
					if ansOne == "Yes"
						array[0] = array[0] + 1
					end
					array[1] = array[1] + 1
					hash[compareOne] = array
				end

				if !hash.has_key? compareTwo
					twoArray = Array.new
					if ansTwo == "Yes" 
						twoArray[0] = 1
					else
						twoArray[0] = 0
					end
					twoArray[1] = 1
					hash[compareTwo] = twoArray
				else
					array = hash[compareTwo]
					if ansTwo == "Yes"
						array[0] = array[0] + 1
					end
					array[1] = array[1] + 1
					hash[compareTwo] = array
				end

				if !hash.has_key? compareThree
					threeArray = Array.new
					if ansThree == "Yes" 
						threeArray[0] = 1
					else
						threeArray[0] = 0
					end
					threeArray[1] = 1
					hash[compareThree] = threeArray
				else
					array = hash[compareThree]
					if ansThree == "Yes"
						array[0] = array[0] + 1
					end
					array[1] = array[1] + 1
					hash[compareThree] = array
				end
				@mainHash[mainPiece] = hash	
			end	
		end
		getComplements item
	end

	def getComplements(item)
		@currentRoom[0] = item
		type = @typeLookup[item]
		type = type.strip

		loveCount = 0
		footCount = 0
		sofaCount = 0
		storCount = 0

		while sofaCount < @numSofa
			getSofa
			sofaCount = sofaCount + 1
		end

		while loveCount < @numLove
			getLove
			loveCount = loveCount + 1
		end

		while storCount < @numStorage
			getStorage
			storCount = storCount + 1
		end

		while footCount < @numFoot
			getFoot
			footCount = footCount + 1
		end

		# if type == "loveseat"
		# 	getSofa
		# 	getFoot
		# 	getStorage
		# end
		# if type == "sofa"
		# 	getStorage
		# 	getFoot 
		# 	getLove
		# end
		# if type == "storage"
		# 	getSofa
		# 	getLove
		# 	getFoot
		# end
		# if type == "footstool"
		# 	getSofa
		# 	getLove
		# 	getStorage
		# end
		@room = File.open("room.html", "w")
		@room.puts "<html><head><title>Room</title></head><body>"
		@currentRoom.each do | furn |
			img_to_tag furn
		end

	end

	def img_to_tag item
		@room.puts "<img width=\"100px\" src=\" #{item} \" />"
		@room.puts("<hr>")
	end


	def getSofa
		sofaScore = Hash.new
		sofas = @types["sofa"]
		sofas.each do | sofa |
			if !@currentRoom.include? sofa
				sofaScore[sofa] = 0.0
				@currentRoom.each do | currentPiece |
					hash = @mainHash[currentPiece]
					if hash.has_key? sofa
						sofaScore[sofa] = sofaScore[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil  
							if hash.has_key? currentPiece
								sofaScore[sofa] = sofaScore[sofa] + (hash[currentPiece][0] / (1.0 * hash[currentPiece][1]))
							end
						end
					end
				end
			end
		end

		currentBest = 0
		winner = ""

		bestPicks = Array.new
		sofaScore.each do |k, v|
			if v > currentBest
				currentBest = v
				bestPicks.clear
				bestPicks << k
			elsif v == currentBest
				bestPicks << k
			end
		end

		itemToAdd = bestPicks.sample
		while @currentRoom.include? itemToAdd
			itemToAdd = bestPicks.sample
		end

		@currentRoom << itemToAdd
	end

	def getFoot
		sofaScore = Hash.new
		sofas = @types["footstool"]
		sofas.each do | sofa |
			if !@currentRoom.include? sofa
				sofaScore[sofa] = 0.0
				@currentRoom.each do | currentPiece |
					hash = @mainHash[currentPiece]
					if hash.has_key? sofa
						sofaScore[sofa] = sofaScore[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil  
							if hash.has_key? currentPiece
								sofaScore[sofa] = sofaScore[sofa] + (hash[currentPiece][0] / (1.0 * hash[currentPiece][1]))
							end
						end
					end
				end
			end
		end

		currentBest = 0
		winner = ""

		bestPicks = Array.new
		sofaScore.each do |k, v|
			if v > currentBest
				currentBest = v
				bestPicks.clear
				bestPicks << k
			elsif v == currentBest
				bestPicks << k
			end
		end

		itemToAdd = bestPicks.sample
		while @currentRoom.include? itemToAdd
			itemToAdd = bestPicks.sample
		end
		
		@currentRoom << itemToAdd
	end

	def getStorage
		sofaScore = Hash.new
		sofas = @types["storage"]
		sofas.each do | sofa |
			if !@currentRoom.include? sofa
				sofaScore[sofa] = 0.0
				@currentRoom.each do | currentPiece |
					hash = @mainHash[currentPiece]
					if hash.has_key? sofa
						sofaScore[sofa] = sofaScore[sofa] + (hash[sofa][0] / (hash[sofa][1] * 1.0))
					else
						hash = @mainHash[sofa]
						if hash != nil  
							if hash.has_key? currentPiece
								sofaScore[sofa] = sofaScore[sofa] + (hash[currentPiece][0] / (1.0 * hash[currentPiece][1]))
							end
						end
					end
				end
			end
		end

		currentBest = 0
		winner = ""

		bestPicks = Array.new
		sofaScore.each do |k, v|
			if v > currentBest
				currentBest = v
				bestPicks.clear
				bestPicks << k
			elsif v == currentBest
				bestPicks << k
			end
		end


		itemToAdd = bestPicks.sample
		while @currentRoom.include? itemToAdd
			itemToAdd = bestPicks.sample
		end
		
		@currentRoom << itemToAdd
	end

	def getLove
		sofaScore = Hash.new
		sofas = @types["loveseat"]
		sofas.each do | sofa |
			if !@currentRoom.include? sofa
				sofaScore[sofa] = 0.0
				@currentRoom.each do | currentPiece |
					hash = @mainHash[currentPiece]
					if hash.has_key? sofa
						sofaScore[sofa] = sofaScore[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil  
							if hash.has_key? currentPiece
								sofaScore[sofa] = sofaScore[sofa] + (hash[currentPiece][0] / (1.0 * hash[currentPiece][1]))
							end
						end
					end
				end
			end
		end

		currentBest = 0
		winner = ""

		bestPicks = Array.new
		sofaScore.each do |k, v|
			if v > currentBest
				currentBest = v
				bestPicks.clear
				bestPicks << k
			elsif v == currentBest
				bestPicks << k
			end
		end


		itemToAdd = bestPicks.sample
		while @currentRoom.include? itemToAdd
			itemToAdd = bestPicks.sample
		end
		
		@currentRoom << itemToAdd
	end
end

RoomCluster.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4])