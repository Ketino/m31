require 'spec_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

describe SisWorker do

	it "worker work" do
		expect {
		  SisWorker.perform_async("foo", "bar")
		}.to change(SisWorker.jobs, :size).by(1)
	end

end