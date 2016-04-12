require 'mturk'
require 'erb'
require './FileUtils.rb'

class Binder
  attr_accessor :imageOne, :imageTwo, :imageThree, :imageFour, :imageFive
  def template_binding
    binding
  end
end

class AutoHits
	def initialize(d,sampleSize)
		@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Production
    fu = FileUtils.new
    sample = fu.furniture.sample(sampleSize)
    (0..sampleSize-1).each do |id|
      sample[id]["uid"] = id.to_s
    end
    count = 0
    n = 0
    while (n<sampleSize) 
      m = n+1        
      while (m<sampleSize)
        base = sample[n]
        cap = m+d-1
        if cap >= sampleSize
          compare = []
          (m..cap).each do |i|
            compare << sample[i%sampleSize]
          end
        else
          compare = sample[m..cap]
        end
        count+=1
        dup = rand(0..2)
        dupped = [0,1,2]<<dup
        perm = dupped.permutation.to_a[rand(0..5)]

        puts perm.to_s
        pair = [perm.index(dup), perm.rindex(dup)]
        reordered = []
        perm.each do |f|
          reordered << compare[f]
        end
        reordered[pair[0]]["ans"] = pair[1]
        reordered[pair[1]]["ans"] = pair[0]
        editXML(base,reordered)
        createNewHit(base,reordered)
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
      :AutoApprovalDelayInSeconds => 86400,
    	:Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
    	:Question => question,
    	:Keywords => keywords )

   	  puts "Created HIT: #{result[:HITId]}"
  	  puts "HIT Location: #{getHITUrl( result[:HITTypeId] )}"
      rootDir = File.dirname $0;
      Amazon::Util::DataReader.save( File.join( rootDir, "hits_created" ), 
        [{:HITId => result[:HITId], 
          :baseName => base["name"], 
          :baseUrl => base["url"],                                                                             
          :compareName1 => compare[0]["name"],
          :compareUrl1 => compare[0]["url"],
          :compareName2 => compare[1]["name"],
          :compareUrl2 => compare[1]["url"],
          :compareName3 => compare[2]["name"],
          :compareUrl3 => compare[2]["url"],
          :compareName4 => compare[3]["name"],
          :compareUrl4 => compare[3]["url"],
          :answer1 => compare[0]["ans"],
          :answer2 => compare[1]["ans"],
          :answer3 => compare[2]["ans"],
          :answer4 => compare[3]["ans"],
          }], :Tabular )
   	end

   	def getHITUrl( hitTypeId )
      return "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Sandbox Url
      # return "http://mturk.com/mturk/preview?groupId=#{hitTypeId}"
	  end

    def editXML(base,compare)
      new_file = File.open("result.xml", "w+")
      template = File.read("template.erb")
      binder = Binder.new
      binder.imageOne = base["url"]
      binder.imageTwo = compare[0]["url"]
      binder.imageThree = compare[1]["url"]
      binder.imageFour = compare[2]["url"]
      binder.imageFive = compare[3]["url"]
      new_file << ERB.new(template).result(binder.template_binding)
      new_file.close
    end
end

AutoHits.new(3,100)


