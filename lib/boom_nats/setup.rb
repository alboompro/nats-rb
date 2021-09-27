module BoomNats::Setup
  mattr_accessor :application

  def setup(&block)
    BoomNats.application ||= BoomNats::Application.new
    BoomNats.application.setup(&block) if block_given?
    BoomNats.application
  end
end
