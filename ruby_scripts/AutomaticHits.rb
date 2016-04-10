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
	def initialize
		@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox
    fu = FileUtils.new
    sample = fu.furniture.sample(200)

    n = 0
    while (n<=199) 
        m = n+1        
        while (m <= 199)
          img1 = sample[n]["url"]
          img2 = sample[m]["url"]
          img3 = sample[m+1]["url"]
          img4 = sample[m+2]["url"]       
          m+=3
          editXML(img1,img2,img3,img4)
    		  createNewHit(sample[n],sample[m])
        end
        m += 4
    end
	end

	def createNewHit(item1,item2)
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
      Amazon::Util::DataReader.save( File.join( rootDir, "hits_created" ), [{:HITId => result[:HITId], 
                                                                            :Name1 => item1["name"], 
                                                                            :Name2 => item2["name"],
                                                                            :Url1 => item1["url"],                                                                             
                                                                            :Url2 => item2["url"],                                                                             
                                                                            }], :Tabular )

   	end

   	def getHITUrl( hitTypeId )
      return "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Sandbox Url
	  end

    def editXML(img1,img2)
      new_file = File.open("result.xml", "w+")
      template = File.read("template.erb")
      binder = Binder.new
      binder.imageOne = img1
      binder.imageTwo = img2
      new_file << ERB.new(template).result(binder.template_binding)
      new_file.close
    end
end

AutoHits.new()


