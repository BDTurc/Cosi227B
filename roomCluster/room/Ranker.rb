require 'json'
class Ranker
	def initialize(item)

		@types = Hash.new
		@typeLookup = Hash.new
		getTypes
		@footstoolRanking = Hash.new
		@sofaRanking = Hash.new
		@loveseatRanking = Hash.new
		@storageRanking = Hash.new
		@mainHash = Hash.new
		@footResult = Array.new
		@sofaResult = Array.new
		@loveseatResult = Array.new
		@storageResult = Array.new
		@item = item
		compare item
		rank
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

	def rank
		getSofa
		getLoveseat
		getStorage
		getFoot

		@loveseatResult = @loveseatRanking.sort_by {|key, value| value}.reverse
		@sofaResult = @sofaRanking.sort_by {|key, value| value}.reverse
		@storageResult = @storageRanking.sort_by {|key, value| value}.reverse
		@footResult = @footstoolRanking.sort_by {|key, value| value}.reverse

		@loveseatResult = cleanArray(@loveseatResult)
		@sofaResult = cleanArray(@sofaResult)
		@storageResult = cleanArray(@storageResult)
		@footResult = cleanArray(@footResult)

		loveseat = File.open("loveseat.json","w")
		sofa = File.open("sofa.json", "w")
		storage = File.open("storage.json", "w")
		foot = File.open("foot.json", "w")

		loveseat.write(@loveseatResult.to_json)
		loveseat.close

		sofa.write(@sofaResult.to_json)
		sofa.close

		storage.write(@storageResult.to_json)
		storage.close

		foot.write(@footResult.to_json)
		foot.close

	end

	def cleanArray(itemArray)
		returnArray = Array.new

		itemArray.each do | item |
			returnArray << item[0]
		end

		return returnArray
	end

	def compare(item)
		results = File.open("../clustering/results_all")
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
	end

	def getSofa
		sofas = @types["sofa"]
		sofas.each do | sofa |
			if !@sofaRanking.include? sofa
				@sofaRanking[sofa] = 0.0
				hash = @mainHash[@item]
					if hash != nil && hash.has_key? sofa
						@sofaRanking[sofa] = @sofaRanking[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil
							if hash.has_key? @item
								@sofaRanking[sofa] = @sofaRanking[sofa] + (hash[@item][0] / (1.0 * hash[@item][1]))
							end
						end
					end
			end
		end
	end


	def getFoot
		sofas = @types["footstool"]
		sofas.each do | sofa |
			if !@footstoolRanking.include? sofa
				@footstoolRanking[sofa] = 0.0
				hash = @mainHash[@item]
					if hash != nil && hash.has_key? sofa
						@footstoolRanking[sofa] = @footstoolRanking[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil
							if hash.has_key? @item
								@footstoolRanking[sofa] = @footstoolRanking[sofa] + (hash[@item][0] / (1.0 * hash[@item][1]))
							end
						end
					end
			end
		end
	end


	def getLoveseat
		sofas = @types["loveseat"]
		sofas.each do | sofa |
			if !@loveseatRanking.include? sofa
				@loveseatRanking[sofa] = 0.0
				hash = @mainHash[@item]
					if hash != nil && hash.has_key? sofa
						@loveseatRanking[sofa] = @loveseatRanking[sofa]  + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil
							if hash.has_key? @item
								@loveseatRanking[sofa]  = @loveseatRanking[sofa]  + (hash[@item][0] / (1.0 * hash[@item][1]))
							end
						end
					end
			end
		end
	end


	def getStorage
		sofas = @types["storage"]
		sofas.each do | sofa |
			if !@storageRanking.include? sofa
				@storageRanking[sofa] = 0.0
				hash = @mainHash[@item]
					if hash != nil && hash.has_key? sofa
						@storageRanking[sofa] = @storageRanking[sofa] + (hash[sofa][0] / (1.0 * hash[sofa][1]))
					else
						hash = @mainHash[sofa]
						if hash != nil
							if hash.has_key? @item
								@storageRanking[sofa] = @storageRanking[sofa] + (hash[@item][0] / (1.0 * hash[@item][1]))
							end
						end
					end
			end
		end
	end


end #class end
