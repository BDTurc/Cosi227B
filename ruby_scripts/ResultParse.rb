class ResultParse
	def initialize()
    cleanseQuestions
	end

  def cleanseQuestions
    content = File.open("results_0429", "r")
    content_clean = File.open("results_clean0429", "w")
    content_clean.puts "assignmentId,workerId,hitId,imgOne,imgTwo,ansOne,imgOne,imgThree,ansTwo,imgOne,imgFour,ansThree,imgOne,imgFive,ansFour"
    urls = Array.new
    answers = Array.new
    workerid = ""
    hitid = ""
    assignmentid = ""
    content.each_line do |row|
      words = row.split(" ")
      if words[0] ==  "2016-04-29"
      if answers[0] != "" && answers[0] != nil
        content_clean.puts "#{assignmentid},#{workerid},#{hitid},#{urls[0]},#{urls[1]},#{answers[0]},#{urls[2]},#{urls[3]},#{answers[1]},#{urls[4]},#{urls[5]},#{answers[2]},#{urls[6]},#{urls[7]},#{answers[3]}"
      end
        urls.clear
        answers.clear
        workerid = ""
        hitid = ""
        assignmentid = ""
      end

      if words[0] != "" && words[0] != nil

        if words[0].include? "DataURL"
           url = words[0]
           url[0..8]=''
           url[url.length-10..url.length] =''
           urls << url
        end
      end

      if words[0] == "\"" 
        if words[1] == "No" || words[1] == "Yes"
          answers << words[1]
          answers << words[2]
          answers << words[3]
          answers << words[4]
          assignmentid = words[6]
          hitid = words[37]
        end
        if words[1] == "True"
          workerid = words[11]
        end
     end
    end
  end
end

ResultParse.new()


