require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('calculation_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')

    pre_test
    test_adding_a_numeric_data_type_and_a_static_number
    test_subtracting_a_numeric_data_type_and_a_static_number
    test_dividing_a_numeric_data_type_and_a_static_number
    test_multiplying_a_numeric_data_type_and_a_static_number
    test_adding_a_numeric_data_type_and_pi
    test_adding_a_numeric_data_type_and_eulers_number
    test_a_numeric_data_type_to_the_power_of_a_static_number
    test_root_of_a_numeric_data_type
    test_log_of_a_numeric_data_type
    test_natural_log_of_a_numeric_data_type
    test_absolute_value_of_a_numeric_data_type
    test_quantity_value
    test_adding_an_invalid_calculation_errors

  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_numeric
  end

  def test_adding_a_numeric_data_type_and_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_subtracting_a_numeric_data_type_and_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.minus
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_dividing_a_numeric_data_type_and_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.divide
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_multiplying_a_numeric_data_type_and_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.multiply
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_numeric_data_type_and_pi
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.pi
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_numeric_data_type_and_eulers_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.e
    @mc.phase_step.calculation_step.save
  end

  def test_a_numeric_data_type_to_the_power_of_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.power
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_root_of_a_numeric_data_type
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.root
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.save
  end

  def test_log_of_a_numeric_data_type
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.log
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.save
  end

  def test_natural_log_of_a_numeric_data_type
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.ln
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.save
  end

  def test_absolute_value_of_a_numeric_data_type
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.absolute
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.save
  end

  def test_quantity_value
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 1
    @mc.phase_step.calculation_step.add_data_step '#'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_adding_an_invalid_calculation_errors
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    assert @mc.phase_step.calculation_step.error_element.visible?,
           "There should be an error on the calculation."
    assert @mc.phase_step.calculation_step.save_element.attribute("disabled"),
           "The save button should be disabled."
  end

end
