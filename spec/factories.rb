FactoryBot.define do
  
    factory :image do
        picture { Rack::Test::UploadedFile.new(File.open('/Users/inito/downloads/image2.avif')) }
    end
end
