describe ThingsHelper, type: :helper do
  describe "#highlighted_content" do
    context "query supplied" do
      it "highlights words from search query" do
        result = helper.highlighted_content("running fox", "run")
        expect(result).to eq("<span class=\"highlight\">running</span> fox")
      end
    end

    context "query is empty" do
      it "returns content as-is" do
        expect(helper.highlighted_content("running fox", nil)).to eq("running fox")
      end
    end
  end
end
