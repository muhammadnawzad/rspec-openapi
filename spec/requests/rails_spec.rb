ENV['TZ'] ||= 'UTC'
ENV['RAILS_ENV'] ||= 'test'
ENV['OPENAPI_OUTPUT'] ||= 'yaml'

require File.expand_path('../rails/config/environment', __dir__)
require 'rspec/rails'

RSpec::OpenAPI.request_headers = %w[X-Authorization-Token]
RSpec::OpenAPI.path = File.expand_path("../rails/doc/openapi.#{ENV['OPENAPI_OUTPUT']}", __dir__)
RSpec::OpenAPI.comment = <<~COMMENT
  This file is auto-generated by rspec-openapi https://github.com/k0kubun/rspec-openapi

  When you write a spec in spec/requests, running the spec with `OPENAPI=1 rspec` will
  update this file automatically. You can also manually edit this file.
COMMENT
RSpec::OpenAPI.server_urls = ['http://localhost:3000']

RSpec.describe 'Tables', type: :request do
  describe '#index' do
    context it 'returns a list of tables' do
      it 'with flat query parameters' do
        get '/tables', params: { page: '1', per: '10' },
                       headers: { authorization: 'k0kubun', "X-Authorization-Token": 'token' }
        expect(response.status).to eq(200)
      end

      it 'with deep query parameters' do
        get '/tables', params: { filter: { "name" => "Example Table" } }, headers: { authorization: 'k0kubun' }
        expect(response.status).to eq(200)
      end

      it 'with different deep query parameters' do
        get '/tables', params: { filter: { "price" => 0 } }, headers: { authorization: 'k0kubun' }
        expect(response.status).to eq(200)
      end
    end

    it 'has a request spec which does not make any request' do
      expect(request).to eq(nil)
    end

    it 'does not return tables if unauthorized' do
      get '/tables'
      expect(response.status).to eq(401)
    end
  end

  describe '#show' do
    it 'returns a table' do
      get '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'does not return a table if unauthorized' do
      get '/tables/1'
      expect(response.status).to eq(401)
    end

    it 'does not return a table if not found' do
      get '/tables/2', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    it 'returns a table' do
      post '/tables', headers: { authorization: 'k0kubun', 'Content-Type': 'application/json' }, params: {
        name: 'k0kubun',
        description: 'description',
        database_id: 2,
      }.to_json
      expect(response.status).to eq(201)
    end
  end

  describe '#update' do
    before do
      png = 'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAAAAADhZOFXAAAADklEQVQIW2P4DwUMlDEA98A/wTjP
      QBoAAAAASUVORK5CYII='.unpack('m').first
      IO.binwrite('test.png', png)
    end
    let(:image) { Rack::Test::UploadedFile.new('test.png', 'image/png') }
    it 'returns a table' do
      patch '/tables/1', headers: { authorization: 'k0kubun' }, params: { image: image }
      expect(response.status).to eq(200)
    end
  end

  describe '#destroy' do
    it 'returns a table' do
      delete '/tables/1', headers: { authorization: 'k0kubun' }
      expect(response.status).to eq(200)
    end

    it 'returns no content if specified' do
      delete '/tables/1', headers: { authorization: 'k0kubun' }, params: { no_content: true }
      expect(response.status).to eq(202)
    end
  end
end

RSpec.describe 'Images', type: :request do
  describe '#payload' do
    it 'returns a image payload' do
      get '/images/1'
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'Extra routes', type: :request do
  describe '#test_block' do
    it 'returns the block content' do
      get '/test_block'
      expect(response.status).to eq(200)
    end
  end
end

RSpec.describe 'Engine test', type: :request do
  describe 'engine routes' do
    it 'returns some content from the engine' do
      get '/my_engine/eng_route'
      expect(response.status).to eq(200)
    end
  end
end
