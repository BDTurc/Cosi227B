require 'mturk'
require 'erb'

class Binder
  attr_accessor :imageOne, :imageTwo
  def template_binding
    binding
  end
end

class AutoHits
	def initialize
		@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox
    editXML
		createNewHit
	end

	def createNewHit
  	 title = "Furniture Comparison"
  	 desc = "This is a single question to determine how similar two pieces of furniture are ."
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
   	end

   	def getHITUrl( hitTypeId )
      return "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}"   # Sandbox Url
	  end

    def editXML()
      new_file = File.open("result.xml", "w+")
      template = File.read("template.erb")
      binder = Binder.new
      binder.imageOne = "http://www.ikea.com/PIAimages/0141999_PE301926_S3.JPG"
      binder.imageTwo = "http://www.ikea.com/PIAimages/0153176_PE311442_S3.JPG"
      new_file << ERB.new(template).result(binder.template_binding)
      new_file.close
    end
end

AutoHits.new()


