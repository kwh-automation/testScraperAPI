# frozen_string_literal: true

require 'mastercontrol-test-suite'
class ProductionRecordsFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @password = env['password']
    @product_name = uniq('s-12246_mastertemplate_')
    @lot_number = uniq('s-12246_lot_')

    pre_test
    test_existing_non_iterative_numeric_type_can_be_used_in_an_iterative_calculation
    test_output_of_existing_non_iterative_calculation_can_be_used_in_an_iterative_calculation
  end

  def pre_test
    @mc.do.login @admin, @password, approve_trainee: true
    create_master_template
    @mc.do.publish_master_batch_record @product_name, @product_name, user: @user
    @mc.do.create_batch_record "#{@product_name} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_lot @lot_number
  end

  def test_existing_non_iterative_numeric_type_can_be_used_in_an_iterative_calculation
    @mc.ebr_navigation.sidenav_navigate_to "1.1.2"
    add_iterations_with %w[5 8 16]
    @mc.batch_phase_step.table_view
    assert @mc.iterating_phase_table_view.data_capture_exists?(1, 1), 'row 1 data Capture 1 does not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(1, 2), 'row 1 data Capture 2 should not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(2, 2), 'row 2 data Capture 2 should not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(3, 2), 'row 3 data Capture 2 should not exist'
    @mc.ebr_navigation.sidenav_navigate_to "1.1.1"
    @mc.phase.phase_steps[0].set_value '3'
    @mc.ebr_navigation.sidenav_navigate_to "1.1.2"
    wait_until { @mc.iterating_phase_table_view.data_capture_exists?(1, 1) }
    assert @mc.iterating_phase_table_view.data_capture_exists?(1, 2), 'row 1 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.data_capture_exists?(2, 2), 'row 2 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.data_capture_exists?(3, 2), 'row 3 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(1, data_capture_order: 2) == '8',
           'row 1 data capture 2 should be 8'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(2, data_capture_order: 2) == '11',
           'row 2 data capture 2 should be 11'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(3, data_capture_order: 2) == '19',
           'row 3 data capture 2 should be 19'
  end

  def test_output_of_existing_non_iterative_calculation_can_be_used_in_an_iterative_calculation
    @mc.ebr_navigation.sidenav_navigate_to "1.1.4"
    add_iterations_with %w[22 18 2]
    @mc.batch_phase_step.table_view
    assert @mc.iterating_phase_table_view.data_capture_exists?(1, 1), 'row 1 data Capture 1 does not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(1, 2), 'row 1 data Capture 2 should not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(2, 2), 'row 2 data Capture 2 should not exist'
    assert !@mc.iterating_phase_table_view.data_capture_exists?(3, 2), 'row 3 data Capture 2 should not exist'
    @mc.ebr_navigation.sidenav_navigate_to "1.1.3"
    @mc.phase.phase_steps[0].set_value '55'
    @mc.ebr_navigation.sidenav_navigate_to "1.1.4"
    wait_until { @mc.iterating_phase_table_view.data_capture_exists?(1, 1) }
    assert @mc.iterating_phase_table_view.data_capture_exists?(1, 2), 'row 1 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.data_capture_exists?(2, 2), 'row 2 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.data_capture_exists?(3, 2), 'row 3 data Capture 2 should exist'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(1, data_capture_order: 2) == '58',
           'row 1 data capture 2 should be 58'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(2, data_capture_order: 2) == '58',
           'row 2 data capture 2 should be 58'
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(3, data_capture_order: 2) == '58',
           'row 3 data capture 2 should be 58'
  end

  private

  def create_master_template
    @mc.do.create_master_batch_record @product_name, @product_name, phase_count: 4, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.back

    configure_iterative_phase 2, 2, '1.1.1.1', '1.1.2.1'

    @mc.structure_builder.phase_level.select_unit '3'
    @mc.structure_builder.phase_level.settings '3'
    @mc.structure_builder.phase_level.open_phase_builder '3'
    @mc.phase_step.add_numeric
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.3.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.nine
    @mc.phase_step.calculation_step.save
    @mc.phase_step.back

    configure_iterative_phase 4, 2, '1.1.1.1', '1.1.3.1'
  end

  def configure_iterative_phase phase_number, phase_index, non_iterative_order_label, iterative_order_label
    @mc.structure_builder.phase_level.select_unit phase_number
    @mc.structure_builder.phase_level.settings phase_number
    @mc.structure_builder.phase_level.open_phase_builder phase_number
    @mc.phase_builder.phase_iterator
    @mc.phase_step.add_numeric
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase phase_index
    @mc.phase_step.calculation_step.add_data_step non_iterative_order_label
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.choose_phase phase_index + 1
    @mc.phase_step.calculation_step.add_data_step iterative_order_label
    @mc.phase_step.calculation_step.save
    @mc.phase_step.back
  end

  def add_iterations_with array_of_values
    array_of_values.each do |value|
      @mc.batch_phase_step.start_new_iteration
      @mc.phase.phase_steps[0].set_value value
      @mc.phase.phase_steps[0].blur
      @mc.batch_phase_step.table_view
    end
  end
end
