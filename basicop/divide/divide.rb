require 'webrick'

server = WEBrick::HTTPServer.new(:Port => 8080)

class Divide < WEBrick::HTTPServlet::AbstractServlet
    def is_number?
        self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
    end

    def do_GET (request, response)
        n1 = request.query["n1"]
        if #{n1}.is_number? 
            n1 = n1.to_i
        else
            n1 = 1
        end

        n2 = request.query["n2"]
        if #{n2}.is_number? 
            n2 = n2.to_i
        else
            n2 = 1
        end

        result = n1 / n2
        response.body = result.to_s
    end
end

server.mount "/basicop/divide", Divide

trap "INT" do server.shutdown end

server.start
