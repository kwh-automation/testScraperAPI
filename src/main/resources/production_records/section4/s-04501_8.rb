# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S04501_', false)
    @product_id = uniq('1', false)
    @operand_measurement_value = 'kg'
    @calc_measurement_value = 'mL'
    @lot_number = uniq('lot_1_')

    pre_test
    test_add_field_unit_of_measure_property_to_numeric_data_type
    test_unit_of_measure_can_be_added_as_a_property_of_a_calculation_data_type_by_a_user_to_the_output
    test_operands_in_calculation_that_have_unit_of_measure_configured_display_their_unit_of_measure
    test_calculations_configured_with_unit_of_measure_display_correct_unit_of_measure
    test_production_record_execution_units_of_measure_display_appropriate_values
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_add_field_unit_of_measure_property_to_numeric_data_type
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.numeric_data.enable_unit_of_measure
    @mc.phase_step.numeric_data.measurement_value text: @operand_measurement_value
    assert @mc.phase_step.is_unit_of_measure_enabled?, 'Unit of Measure is not enabled'
  end

  def test_unit_of_measure_can_be_added_as_a_property_of_a_calculation_data_type_by_a_user_to_the_output
    adding_a_calculation_step
    @mc.phase_step.enable_unit_of_measure
    @mc.phase_step.calculation_step.measurement_value text: @calc_measurement_value
    assert @mc.phase_step.is_unit_of_measure_enabled?, 'Unit of Measure is not enabled'
  end

  def test_operands_in_calculation_that_have_unit_of_measure_configured_display_their_unit_of_measure
    assert_equals @mc.phase_step.calculation_step.unit_of_measure_calc_operand_value, @operand_measurement_value,
                  'Calculation Operand Unit of Measurement'
    @mc.wait_for_video
  end

  def test_calculations_configured_with_unit_of_measure_display_correct_unit_of_measure
    assert_equals @mc.phase_step.calculation_step.unit_of_measure_calc_output_value, @calc_measurement_value,
                  'Calculation Output Unit of Measurement'
    @mc.wait_for_video
  end

  def test_production_record_execution_units_of_measure_display_appropriate_values
    approve_master_template
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_first 'phase', @lot_number
    assert_equals execution_unit_of_measure(1, '1.1.1.2'), @operand_measurement_value,
                  'First Calculation Unit of Measure for Operand 1'
  end

  private

  def adding_a_calculation_step
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def approve_master_template
    @mc.structure_builder.back
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def execution_unit_of_measure(step, step_label, index: 0)
    @mc.phase.phase_steps[step].calc_phase_step_operands_unit_of_measure(step_label, index: index)
  end
end
