class Similarity
	def initialize(item, type)
		if type == "parse"
			parse
		end
		if type == "basic"
			@exemplars = Hash.new
			getExemplars
			lookupSimilarAffinity item
		end
		if type == "new"
			lookupSimilarityAffinityPlus item
		end
	end

	def parse
		contents = File.read("../clustering/clusters.txt")
		output = File.open("urls.csv", "w")
		contents.each_line do | row |
			img, cluster_id = row.split(" ")
			output.puts(img)
		end
	end

	def getExemplars
		contents = File.read("../clustering/centers.txt")
		contents.each_line do | row |
			item, id = row.split(" ")
			@exemplars[id] = item
		end
	end

	def lookupSimilarAffinity(item)
		similarity = Hash.new
		key_lookup = Hash.new
		contents = File.read("../clustering/clusters.txt")
		contents.each_line do | row |
			img, cluster_id = row.split(" ")
			if !key_lookup.has_key? img
				key_lookup[img] = cluster_id
			end

			if !similarity.has_key? cluster_id
				array = Array.new
				array << img
				similarity[cluster_id] = array
			else 
				current_array = similarity[cluster_id]
				current_array << img
				similarity[cluster_id] = current_array
			end
		end
		content_array = similarity[key_lookup[item]]
		puts @exemplars[key_lookup[item]]
	end

	def lookupSimilarityAffinityPlus(item)

	end
end

Similarity.new(ARGV[0], ARGV[1])