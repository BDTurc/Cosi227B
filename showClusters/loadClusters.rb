require "json"

class ClusterUtils
	def self.loadClusters
		clusters = Hash.new
		catagories = Hash.new
		file = "./clusters.txt"
		content = File.open(file)
		content.each_line do |row|
			img, cn, catagory = row.split(' ')
			clusters[img] = cn
			catagories[img] = catagory
		end
		File.open("clusters.json", 'w') { |file| file.write(clusters.to_json) }
		File.open("catagories.json", 'w') { |file| file.write(catagories.to_json) }		
	end

	def self.loadCenters
		centers = Hash.new
		file = "./centers.txt"
		content = File.open(file)
		content.each_line do |row|
			img, cn = row.split(' ')
			centers[cn] = img
		end
		File.open("centers.json", 'w') { |file| file.write(centers.to_json) }
	end
end

ClusterUtils.loadCenters
ClusterUtils.loadClusters