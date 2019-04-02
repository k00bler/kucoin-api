RSpec.describe Kucoin::Api::REST do
  let(:client) { described_class.new }
  subject { client }

  it { expect(described_class::BASE_URL).to eq 'https://openapi-v2.kucoin.com' }
  it { expect(described_class::SANDBOX_BASE_URL).to eq 'https://openapi-sandbox.kucoin.com' }
  it { expect(described_class::API_KEY).to eq '' }
  it { expect(described_class::API_SECRET).to eq '' }
  it { expect(described_class::API_PASSPHRASE).to eq '' }

  describe "endpoint_methods" do
    Kucoin::Api::ENDPOINTS.keys.each do |endpoint_name|
      it "#{endpoint_name}" do
        expect(subject.public_send(endpoint_name)).to be_a Kucoin::Api::Endpoints.get_klass(endpoint_name)
        expect(subject.public_send(endpoint_name).client).to eq subject
      end
    end
  end

  describe '#base_url' do
    it { expect(subject.base_url).to eq described_class::BASE_URL }
    it { expect(subject.sandbox?).to be_falsey }
    describe 'for sandbox' do
      let(:client) { described_class.new(sandbox: true) }
      it { expect(subject.base_url).to eq described_class::SANDBOX_BASE_URL }
      it { expect(subject.sandbox?).to be_truthy }
    end
  end

  describe '#open' do
    let(:endpoint) { subject.account }
    it do
      expect(Kucoin::Api::REST::Connection).to receive(:new).with(endpoint, url: Kucoin::Api::REST::BASE_URL).and_call_original
      connection = subject.open(endpoint)
      expect(connection.client.builder.handlers).to include(FaradayMiddleware::EncodeJson, FaradayMiddleware::ParseJson)
    end
  end

  describe '#auth' do
    let(:client) { described_class.new(api_key: 'foo', api_secret: 'bar') }
    let(:endpoint) { subject.account }
    it do
      expect(Kucoin::Api::REST::Connection).to receive(:new).with(endpoint, url: Kucoin::Api::REST::BASE_URL).and_call_original
      connection = subject.auth(endpoint)
      expect(connection.client.builder.handlers).to include(FaradayMiddleware::EncodeJson, FaradayMiddleware::ParseJson, Kucoin::Api::Middleware::NonceRequest, Kucoin::Api::Middleware::AuthRequest)
    end
  end
end
