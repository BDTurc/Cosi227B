class FileUtils

	attr_accessor :furniture

	def initialize
		self.furniture = Array.new
		loadDataFiles
	end

	def loadDataFiles
		dir = '../data'+File::SEPARATOR
		allFiles = Dir[dir+"*.csv"]
		allFiles.each do |f|
			self.furniture.concat(loadFurntureData(f))
		end
		return furniture
	end

	def loadFurntureData(fn)
		puts "processing" + fn
		output = Array.new
		content = File.open(fn, "r:iso-8859-1")
		content.each_line do |row|
			name, url = row.delete("\"").split(',')
			idx = url.index(".JPG")
			if idx == nil
				idx = url.index(".jpg")
			end
			if idx == nil
				idx = url.length-1
			else
				idx += 3
			end
			data = {"name" => name, "url" => url[0..idx]}
			output << data
			# puts data
		end
		content.close
		return output
	end
end

fu = FileUtils.new

puts fu.furniture