# encoding: utf-8

module Uplink
  class Application < Sinatra::Base
    get "/" do
      { "hejs" => "dejs" }.bencode
    end

    get "/stats" do
      { "Software" => "Uplink v#{Version}" }.bencode
    end
  end
end
