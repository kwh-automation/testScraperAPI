# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('s-08553_', false)
    @product_id = uniq('1', false)
    @test_mbr = "#{@product_id} #{@product_name}"
    @lot_number = uniq('lot_')
    @first_data = 3
    @second_data = 5

    pre_test
    test_configuring_numeric_data_types_to_display_aggregations_on_tables
    test_configuring_calculation_types_to_display_aggregations_on_tables
    test_aggregations_of_numeric_data_display_on_table_when_configured
    test_aggregations_of_calculation_step_display_on_table_when_configured
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_configuring_numeric_data_types_to_display_aggregations_on_tables
    @mc.phase_step.phase_iterator
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step Sum'
    @mc.phase_step.numeric_data.enable_aggregation_types
    @mc.phase_step.numeric_data.choose_aggregation_type 'Sum'
    assert @mc.phase_step.numeric_data.is_aggregation_types_enabled?, 'Aggregations is not enabled with Sum selected.'
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '2', text: 'Numeric Step Average'
    @mc.phase_step.numeric_data.enable_aggregation_types
    @mc.phase_step.numeric_data.choose_aggregation_type 'Average'
    assert @mc.phase_step.numeric_data.is_aggregation_types_enabled?, 'Aggregations is not enabled with Average selected.'
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '3', text: 'Numeric Step Standard Deviation'
    @mc.phase_step.numeric_data.enable_aggregation_types
    @mc.phase_step.numeric_data.choose_aggregation_type 'Standard Deviation'
    assert @mc.phase_step.numeric_data.is_aggregation_types_enabled?, 'Aggregations is not enabled with Standard Deviations selected.'
  end

  def test_configuring_calculation_types_to_display_aggregations_on_tables
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save

    @mc.phase_step.calculation_step.enable_aggregation_types
    @mc.phase_step.calculation_step.choose_aggregation_type 'Sum'
    @mc.phase_step.calculation_step.choose_aggregation_type 'Average'
    @mc.phase_step.calculation_step.choose_aggregation_type 'Standard Deviation'

    assert @mc.phase_step.calculation_step.is_aggregation_types_enabled?, 'Aggregations is not enabled.'
  end

  def test_aggregations_of_numeric_data_display_on_table_when_configured
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record @test_mbr, @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)

    wait_until { @mc.batch_phase_step.start_new_iteration_element.visible? }

    complete_new_iteration @first_data
    complete_new_iteration @second_data

    @mc.batch_phase_step.table_view

    assert_equals @mc.iterating_phase_table_view.sum_aggregation(1), '8',
                  'Sum aggregation for numeric input in column 1 check failed'
    assert_equals @mc.iterating_phase_table_view.average_aggregation(2), '4',
                  'Average aggregation for numeric input in column 2 check failed'
    assert_equals @mc.iterating_phase_table_view.standard_deviation_aggregation(3), '1',
                  'Standard Deviation aggregation for numeric input in column 3 check failed'
    @mc.wait_for_video
  end

  def test_aggregations_of_calculation_step_display_on_table_when_configured
    assert_equals @mc.iterating_phase_table_view.sum_aggregation(4), '10',
                  'Sum aggregation for calculation in column 4 check failed'
    assert_equals @mc.iterating_phase_table_view.average_aggregation(4), '5',
                  'Average aggregation for calculation in column 4 check failed'
    assert_equals @mc.iterating_phase_table_view.standard_deviation_aggregation(4), '1',
                  'Standard Deviation aggregation for calculation in column 4 check failed'
    @mc.wait_for_video
  end

  private

  def complete_new_iteration(numeric_step_input)
    @mc.batch_phase_step.start_new_iteration
    @mc.phase.phase_steps[0].set_value numeric_step_input
    @mc.phase.phase_steps[0].blur

    @mc.phase.phase_steps[1].set_value numeric_step_input
    @mc.phase.phase_steps[1].blur

    @mc.phase.phase_steps[2].set_value numeric_step_input
    @mc.phase.phase_steps[2].blur

    @mc.phase.completion.complete
    wait_until { @mc.batch_phase_step.table_view? }
  end
end
