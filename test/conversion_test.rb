require "test_helper"

class Measured::ConversionTest < ActiveSupport::TestCase
  setup do
    @base = Measured::Unit.new(:m)
    @units = [
      Measured::Unit.new(:in, aliases: [:Inch], value: "0.0254 m"),
      Measured::Unit.new(:ft, aliases: [:Feet, :Foot], value: "0.3048 m"),
    ]

    @conversion = Measured::Conversion.new(@base, @units)
  end

  test "#unit_names_with_aliases lists all allowed unit names" do
    assert_equal ["Feet", "Foot", "Inch", "ft", "in", "m"], @conversion.unit_names_with_aliases
  end

  test "#unit_names lists all base unit names without aliases" do
    assert_equal ["ft", "in", "m"], @conversion.unit_names
  end

  test "#unit? checks if the unit is part of the units but not aliases" do
    assert @conversion.unit?(:in)
    assert @conversion.unit?("m")
    refute @conversion.unit?("M")
    refute @conversion.unit?("inch")
    refute @conversion.unit?(:yard)
  end

  test "#unit? with blank and nil arguments" do
    refute @conversion.unit?("")
    refute @conversion.unit?(nil)
  end

  test "#unit_or_alias? checks if the unit is part of the units or aliases" do
    assert @conversion.unit_or_alias?(:Inch)
    assert @conversion.unit_or_alias?("m")
    assert @conversion.unit_or_alias?("in")
    refute @conversion.unit_or_alias?(:inch)
    refute @conversion.unit_or_alias?(:IN)
    refute @conversion.unit_or_alias?(:yard)
  end

  test "#unit_or_alias? with blank and nil arguments" do
    refute @conversion.unit_or_alias?("")
    refute @conversion.unit_or_alias?(nil)
  end

  test "#to_unit_name converts a unit name to its base unit" do
    assert_equal "fireball", CaseSensitiveMagic.conversion.to_unit_name("fire")
  end

  test "#to_unit_name does not care about string or symbol" do
    assert_equal "fireball", CaseSensitiveMagic.conversion.to_unit_name(:fire)
  end

  test "#to_unit_name passes through if already base unit name" do
    assert_equal "fireball", CaseSensitiveMagic.conversion.to_unit_name("fireball")
  end

  test "#to_unit_name raises if not found" do
    assert_raises Measured::UnitError do
      CaseSensitiveMagic.conversion.to_unit_name("thunder")
    end
  end

  test "#convert raises if either unit is not found" do
    assert_raises Measured::UnitError do
      CaseSensitiveMagic.conversion.convert(1, from: "fire", to: "doesnt_exist")
    end

    assert_raises Measured::UnitError do
      CaseSensitiveMagic.conversion.convert(1, from: "doesnt_exist", to: "fire")
    end
  end

  test "#convert converts between two known units" do
    assert_equal BigDecimal("3"), @conversion.convert(BigDecimal("36"), from: "in", to: "ft")
    assert_equal BigDecimal("18"), @conversion.convert(BigDecimal("1.5"), from: "ft", to: "in")
  end

  test "#convert handles the same unit" do
    assert_equal BigDecimal("2"), @conversion.convert(BigDecimal("2"), from: "in", to: "in")
  end
end
