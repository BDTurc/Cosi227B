require 'mturk'
require 'erb'
require './FileUtils.rb'

class Binder
  attr_accessor :imageOne, :imageTwo, :imageThree, :imageFour
  def template_binding
    binding
  end
end

class AutoHits
	def initialize(d,sampleSize)
		@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox
    fu = FileUtils.new
    sample = fu.furniture.sample(sampleSize)
    count = 0
    n = 0
    while (n<sampleSize) 
      m = n+1        
      while (m<sampleSize)
        base = sample[n]
        cap = m+d-1
        if cap > sampleSize
          compare = []
          (m..cap).each do |i|
            compare << sample[i%sampleSize]
          end
        else
          compare = sample[m..cap]
        end
        count+=1
        editXML(base,compare)
        createNewHit(base,compare)
        m+=d
      end
      n+=1
    end
    puts "total HITs: " + count.to_s
	end

	def createNewHit(base,compare)
  	 title = "Furniture Comparison"
  	 desc = "Two question survey to determine if two pieces of furniture look good together"
  	 keywords = "furniture, survey"
  	 numAssignments = 3
   	 rewardAmount = 0.01

   	 questionFile = "result.xml"
     question = File.read( questionFile )

   	 result = @mturk.createHIT( :Title => title,
    	:Description => desc,
    	:MaxAssignments => numAssignments,
    	:Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
    	:Question => question,
    	:Keywords => keywords )

   	  puts "Created HIT: #{result[:HITId]}"
  	  puts "HIT Location: #{getHITUrl( result[:HITTypeId] )}"
      rootDir = File.dirname $0;
      Amazon::Util::DataReader.save( File.join( rootDir, "hits_created" ), 
        [{:HITId => result[:HITId], 
          :baseName => base["name"], 
          :compareName1 => compare[0]["name"],
          :compareName2 => compare[1]["name"],
          :compareName3 => compare[2]["name"],
          :baseUrl => base["url"],                                                                             
          :compareUrl1 => compare[0]["url"],
          :compareUrl2 => compare[1]["url"],
          :compareUrl3 => compare[2]["url"],
          }], :Tabular )
   	end

   	def getHITUrl( hitTypeId )
      return "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Sandbox Url
	  end

    def editXML(base,compare)
      new_file = File.open("result.xml", "w+")
      template = File.read("template.erb")
      binder = Binder.new
      binder.imageOne = base["url"]
      binder.imageTwo = compare[0]["url"]
      binder.imageThree = compare[1]["url"]
      binder.imageFour = compare[2]["url"]
      new_file << ERB.new(template).result(binder.template_binding)
      new_file.close
    end
end

AutoHits.new(3,200)


