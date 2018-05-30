RSpec.describe Krankorde::Token do
  it "knows the '+' operator" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.is_operator? "+").to be true
  end

  it "knows the '+' operator's type" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.type).to be :operator
  end

  it "knows the '+' operator's value" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.value).to eq "+"
  end

  it "knows the '+' operator's location" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.index).to be 2
  end

  it "knows the '+' operator within others" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.is_operator? "+", "-").to be true
  end

  it "knows the '-' operator within others" do
    plus_op = Krankorde::Token.new(:operator, "-", 2)
    expect(plus_op.is_operator? "+", "-").to be true
  end

  it "doesn't give true for the '+' operator when it's not exists in the list" do
    plus_op = Krankorde::Token.new(:operator, "+", 2)
    expect(plus_op.is_operator? "*", "/").not_to be true
  end

  it "doesn't give true for the '+' operator when it's not an operator token" do
    plus_op = Krankorde::Token.new(:number, "923", 0)
    expect(plus_op.is_operator? "*", "/").not_to be true
  end
end
