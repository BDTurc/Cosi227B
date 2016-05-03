require "json"

class ClusterUtils
	def self.loadClusters
		clusters = Hash.new
		catagories = Hash.new
		file = "/Users/apple/Google Drive/COSI 227B/CleanProj/clustering/archive/all data/ap/clusters.txt"
		content = File.open(file)
		content.each_line do |row|
			# puts row
			img, cn, catagory = row.split(' ')
			clusters[img] = cn
			catagories[img] = catagory
		end
		File.open("clusters.json", 'w') { |file| file.write(clusters.to_json) }
		File.open("catagories.json", 'w') { |file| file.write(catagories.to_json) }
	end

	def self.loadCenters
		centers = Hash.new
		file = "/Users/apple/Google Drive/COSI 227B/CleanProj/clustering/archive/all data/ap/centers.txt"
		content = File.open(file)
		content.each_line do |row|
			img, cn = row.split(' ')
			centers[cn] = img
		end
		puts centers.to_json
		output = File.open("centers.json", "w")
		output.puts(centers.to_json)
	end
end

ClusterUtils.loadCenters
ClusterUtils.loadClusters
