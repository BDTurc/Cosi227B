class Validate 
	def initialize
		#filterBadHits
		filterBadWorkers
	end

	def automaticReject(badHash)
	    contents = File.open("results_clean0429")
	    rejectfile = File.open("rejectFile.txt", "w")
	    contents.each_line do | line |
			assignmentId, workerId, hitId, imgOne, imgTwo, ansOne, imgThree, imgFour, ansTwo, 
			imgFive, imgSix, ansThree, imgSeven, imgEight, ansFour = line.split(",")

			workerId = workerId.strip
			assignmentId = assignmentId.strip

			if(badHash.has_key? workerId)
				rejectfile.puts assignmentId
			end
		end
	end

	def automaticApprove(badHash)
	    contents = File.open("results_clean0429")
	    acceptfile = File.open("acceptFile.txt", "w")
	    contents.each_line do | line |
			assignmentId, workerId, hitId, imgOne, imgTwo, ansOne, imgThree, imgFour, ansTwo, 
			imgFive, imgSix, ansThree, imgSeven, imgEight, ansFour = line.split(",")

			workerId = workerId.strip
			assignmentId = assignmentId.strip
			
			if(!badHash.has_key? workerId)
				acceptfile.puts assignmentId
			end
		end
	end

	def filterBadWorkers
		contents = File.open("results_clean0429")

		badHash = Hash.new
		workerHash = Hash.new

		contents.each_line do | line |
			assignmentId, workerId, hitId, imgOne, imgTwo, ansOne, imgThree, imgFour, ansTwo, 
			imgFive, imgSix, ansThree, imgSeven, imgEight, ansFour = line.split(",")

			if(!workerHash.has_key? workerId)
				workerHash[workerId] = 1
			end

			imgOne = imgOne.strip
			imgTwo = imgTwo.strip
			imgThree = imgThree.strip
			imgFour = imgFour.strip
			imgFive = imgFive.strip
			imgSix = imgSix.strip
			imgSeven = imgSeven.strip
			imgEight = imgEight.strip

			bad = false

			if(duplicate? imgTwo, imgFour)
				if(!duplicate? ansOne, ansTwo)
					bad = true
				end
			elsif(duplicate? imgTwo, imgSix)
				if(!duplicate? ansOne, ansThree)
					bad = true
				end
			elsif(duplicate? imgTwo, imgEight)
				if(!duplicate? ansOne, ansFour)
					bad = true
				end
			elsif(duplicate? imgFour, imgSix)
				if(!duplicate? ansTwo, ansThree)
					bad = true
				end
			elsif(duplicate? imgFour, imgEight)
				if(!duplicate? ansTwo, ansFour)
					bad = true
				end
			elsif(duplicate? imgSix, imgEight)
				if(!duplicate? ansThree, ansFour)
					bad = true
				end
			end

			if bad
				if(badHash.has_key? workerId)
					badHash[workerId] = badHash[workerId] + 1
				else
					badHash[workerId] = 1
				end
			end
		end

		badHash.keys.each do |key|
			if badHash[key] < 40
				badHash.delete(key)
			end
		end
		automaticReject(badHash)
		automaticApprove(badHash)
		#removeBadWorkers(badHash)	
	end

	def removeBadWorkers(badHash)
		writable = File.open("BadWorkersRemoved", "w")
		contents = File.open("results_clean0429", "r")

		contents.each_line do | line |
			assignmentId, workerId, hitId, imgOne, imgTwo, ansOne, imgThree, imgFour, ansTwo, 
			imgFive, imgSix, ansThree, imgSeven, imgEight, ansFour = line.split(",")

			bad = false
			if(badHash.has_key? workerId)
				if(badHash[workerId] >= 30)
					bad = true
				end
			end

			if !bad
				writable.puts line
			end
		end
	end

	def filterBadHits
		writable = File.open("BadHitsRemoved", "w")
		contents = File.open("results_clean0429")

		contents.each_line do | line |
			assignmentId, workerId, hitId, imgOne, imgTwo, ansOne, imgThree, imgFour, ansTwo, 
			imgFive, imgSix, ansThree, imgSeven, imgEight, ansFour = line.split(",")

			imgOne = imgOne.strip
			imgTwo = imgTwo.strip
			imgThree = imgThree.strip
			imgFour = imgFour.strip
			imgFive = imgFive.strip
			imgSix = imgSix.strip
			imgSeven = imgSeven.strip
			imgEight = imgEight.strip

			bad = false
			if(duplicate? imgTwo, imgFour)
				if(!duplicate? ansOne, ansTwo)
					bad = true
					#writable.puts(line)
				end
			elsif(duplicate? imgTwo, imgSix)
				if(!duplicate? ansOne, ansThree)
					bad = true
					#writable.puts(line)
				end
			elsif(duplicate? imgTwo, imgEight)
				if(!duplicate? ansOne, ansFour)
					bad = true
					#writable.puts(line)
				end
			elsif(duplicate? imgFour, imgSix)
				if(!duplicate? ansTwo, ansThree)
					bad = true
					#writable.puts(line)
				end
			elsif(duplicate? imgFour, imgEight)
				if(!duplicate? ansTwo, ansFour)
					bad = true
					#writable.puts(line)
				end
			elsif(duplicate? imgSix, imgEight)
				if(!duplicate? ansThree, ansFour)
					bad = true
					#writable.puts(line)
				end
			end

			if !bad
				writable.puts(line)
			end
		end	
	end

	def duplicate?(itemOne, itemTwo)
		if(itemOne.eql? itemTwo)
			return true
		end

		return false
	end
end

Validate.new()