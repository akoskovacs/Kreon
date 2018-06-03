RSpec.describe Kreon::Tokenizer do
  it "can tokenize operators" do
    t = Kreon::Tokenizer.new(" 23 +\t  -\n/*+")
    t.tokenize
    expect(t.is_current_an? :number).to be true
    expect(t.is_next_an_operator? "+").to be true
    expect(t.is_next_an_operator? "-", "+").to be true
    expect(t.is_next_an_operator? "*", "+", "/").to be true
    expect(t.is_next_an_operator? "*", "/").to be true
    expect(t.is_next_an_operator? "+").to be true
  end
end
