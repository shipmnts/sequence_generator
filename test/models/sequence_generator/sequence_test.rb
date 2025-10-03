require 'test_helper'

module SequenceGenerator
  class SequenceTest < ActiveSupport::TestCase
    # Setup and Teardown
    def setup
      @sequence = Sequence.new(
        name: "INV-(YYYY)-#####",
        scope: "invoices",
        purpose: "invoice_number"
      )
      @test_date = Time.new(2024, 6, 15, 10, 0, 0)
    end

    def teardown #
      Sequence.destroy_all
      CurrentSequence.destroy_all if defined?(CurrentSequence)
    end

    # Validation Tests
    test "should be valid with all required attributes" do
      assert @sequence.valid?
    end

    test "should require name" do
      @sequence.name = nil
      assert_not @sequence.valid?
      assert_includes @sequence.errors[:name], "can't be blank"
    end

    test "should require scope" do
      @sequence.scope = nil
      assert_not @sequence.valid?
      assert_includes @sequence.errors[:scope], "can't be blank"
    end

    test "should require purpose" do
      @sequence.purpose = nil
      assert_not @sequence.valid?
      assert_includes @sequence.errors[:purpose], "can't be blank"
    end

    test "should validate uniqueness of name scoped to scope and purpose" do
      @sequence.save!
      duplicate = Sequence.new(
        name: @sequence.name,
        scope: @sequence.scope,
        purpose: @sequence.purpose
      )
      assert_not duplicate.valid?
      assert_includes duplicate.errors[:name], "has already been taken"
    end

    test "should allow same name with different scope" do
      @sequence.save!
      different_scope = Sequence.new(
        name: @sequence.name,
        scope: "orders",
        purpose: @sequence.purpose
      )
      assert different_scope.valid?
    end

    test "should allow same name with different purpose" do
      @sequence.save!
      different_purpose = Sequence.new(
        name: @sequence.name,
        scope: @sequence.scope,
        purpose: "order_number"
      )
      assert different_purpose.valid?
    end

    # Fragment Resolution Tests
    test "resolve_fragment should return YYYY format" do
      result = @sequence.resolve_fragment("YYYY", mock_model, @test_date)
      assert_equal "2024", result
    end

    test "resolve_fragment should return YY format" do
      result = @sequence.resolve_fragment("YY", mock_model, @test_date)
      assert_equal "24", result
    end

    test "resolve_fragment should return MM format" do
      result = @sequence.resolve_fragment("MM", mock_model, @test_date)
      assert_equal "06", result
    end

    test "resolve_fragment should return slash" do
      result = @sequence.resolve_fragment("/", mock_model, @test_date)
      assert_equal "/", result
    end

    test "resolve_fragment should call model attribute" do
      model = mock_model(branch_code: "BR001")
      result = @sequence.resolve_fragment("branch_code", model, @test_date)
      assert_equal "BR001", result
    end

    # Indian Financial Year Tests
    test "resolve_fragment IFYY should return correct FY after April 1st" do
      date = Time.new(2024, 6, 15) # After April 1st
      result = @sequence.resolve_fragment("IFYY", mock_model, date)
      assert_equal "24-25", result
    end

    test "resolve_fragment IFYY should return correct FY before April 1st" do
      date = Time.new(2024, 3, 15) # Before April 1st
      result = @sequence.resolve_fragment("IFYY", mock_model, date)
      assert_equal "23-24", result
    end

    test "resolve_fragment IFYY should handle April 1st boundary" do
      date = Time.new(2024, 4, 1, 6, 0, 0) # After 5:30 AM on April 1st
      result = @sequence.resolve_fragment("IFYY", mock_model, date)
      assert_equal "24-25", result
    end

    test "resolve_fragment IFY should return correct FY without dash after April 1st" do
      date = Time.new(2024, 6, 15)
      result = @sequence.resolve_fragment("IFY", mock_model, date)
      assert_equal "2425", result
    end

    test "resolve_fragment IFY should return correct FY without dash before April 1st" do
      date = Time.new(2024, 3, 15)
      result = @sequence.resolve_fragment("IFY", mock_model, date)
      assert_equal "2324", result
    end

    # Generate Next Tests
    test "generate_next should create sequence with YYYY placeholder" do
      @sequence.name = "INV-(YYYY)-#####"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      assert_match(/^INV-\d{4}-\d{5}$/, result)
      assert_includes result, Time.now.strftime('%Y')
    end

    test "generate_next should create sequence with YY and MM placeholders" do
      @sequence.name = "ORD-(YY)(MM)-####"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      assert_match(/^ORD-\d{2}\d{2}-\d{4}$/, result)
    end

    test "generate_next should use date_column when provided" do
      @sequence.name = "INV-(YYYY)-#####"
      @sequence.save!
      
      custom_date = Time.new(2023, 1, 15)
      model = mock_model(invoice_date: custom_date)
      
      result = @sequence.generate_next({ date_column: :invoice_date }, model)
      
      assert_includes result, "2023"
    end

    test "generate_next should add default padding if no hash symbols present" do
      @sequence.name = "INV-(YYYY)"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      assert_match(/^INV-\d{4}\d{5}$/, result)
    end

    test "generate_next should respect custom padding length" do
      @sequence.name = "INV-###"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      assert_match(/^INV-\d{3}$/, result)
    end

    test "generate_next should handle suffix after hash symbols" do
      @sequence.name = "INV-#####-SUFFIX"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      assert_match(/^INV-\d{5}-SUFFIX$/, result)
      assert_equal "INV-", result[0..3]
      assert_equal "-SUFFIX", result[-7..-1]
    end

    test "generate_next should handle model attributes in curly braces" do
      @sequence.name = "INV-{branch_code}-(YYYY)-####"
      @sequence.save!
      
      model = mock_model(branch_code: "BR01")
      result = @sequence.generate_next({}, model)
      
      assert_includes result, "BR01"
      assert_match(/^INV-BR01-\d{4}-\d{4}$/, result)
    end

    test "generate_next should handle Indian Financial Year format" do
      @sequence.name = "INV-(IFYY)-####"
      @sequence.save!
      
      date = Time.new(2024, 6, 15) # After April 1st
      model = mock_model(invoice_date: date)
      
      result = @sequence.generate_next({ date_column: :invoice_date }, model)
      
      assert_includes result, "24-25"
      assert_match(/^INV-\d{2}-\d{2}-\d{4}$/, result)
    end

    test "generate_next should handle mixed parentheses and curly braces" do
      @sequence.name = "INV-{branch_code}-(YY)(MM)-####"
      @sequence.save!
      
      date = Time.new(2024, 6, 15)
      model = mock_model(branch_code: "BR01", invoice_date: date)
      
      result = @sequence.generate_next({ date_column: :invoice_date }, model)
      assert_includes result, "BR01"
      assert_includes result, "24"
      assert_includes result, "06"
    end

    test "generate_next should only use parentheses fields for sequence prefix with curly braces" do
      @sequence.name = "INV-{branch_code}-(YYYY)-#####"
      @sequence.save!
      
      # The sequence counter should only consider (YYYY) part, not {branch_code}
      model1 = mock_model(branch_code: "BR01")
      result1 = @sequence.generate_next({}, model1)
      
      model2 = mock_model(branch_code: "BR02")
      result2 = @sequence.generate_next({}, model2)
      
      # Both should have sequential numbers despite different branch codes
      # because sequence prefix only considers () fields
      assert result1.end_with?("00001")
      assert result2.end_with?("00002")
    end
    
    test "generate_next should only use parentheses fields for sequence prefix without curly braces" do
      @sequence.name = "INV-(branch_code)-(YYYY)-#####"
      @sequence.save!
      
      model1 = mock_model(branch_code: "BR01")
      result1 = @sequence.generate_next({}, model1)
      
      model2 = mock_model(branch_code: "BR02")
      result2 = @sequence.generate_next({}, model2)
    
      assert result1.end_with?("00001")
      assert result2.end_with?("00001")
    end

    test "generate_next should format number with leading zeros" do
      @sequence.name = "INV-#####"
      @sequence.save!
      
      model = mock_model
      result = @sequence.generate_next({}, model)
      
      # First call should return 00001
      assert_match(/\d{5}$/, result)
      assert result.end_with?("00001")
    end

    test "generate_next should handle complex pattern" do
      @sequence.name = "INV-{branch_code}-(YYYY)/(MM)-(IFY)-######"
      @sequence.save!
      
      date = Time.new(2024, 6, 15)
      model = mock_model(branch_code: "MUM", invoice_date: date)
      
      result = @sequence.generate_next({ date_column: :invoice_date }, model)
      
      assert_includes result, "MUM"
      assert_includes result, "2024"
      assert_includes result, "06"
      assert_includes result, "2425"
      assert_match(/\d{6}$/, result)
    end

    private

    def mock_model(attributes = {})
      model = Object.new
      attributes.each do |key, value|
        model.define_singleton_method(key) { value }
      end
      model
    end
  end
end
