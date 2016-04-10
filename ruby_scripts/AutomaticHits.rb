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
    100.times do
      img1 = fu.furniture.sample["url"]
      img2 = fu.furniture.sample["url"]
      editXML(img1,img2)
		  createNewHit
    end
	end

	def createNewHit
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
      Amazon::Util::DataReader.save( File.join( rootDir, "hits_created" ), [{:HITId => result[:HITId] }], :Tabular )

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


