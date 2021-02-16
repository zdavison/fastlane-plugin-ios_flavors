describe Fastlane::Actions::IosFlavorsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The ios_flavors plugin is working!")

      Fastlane::Actions::IosFlavorsAction.run(nil)
    end
  end
end
