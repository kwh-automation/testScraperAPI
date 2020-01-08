# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']

    pre_test
    test_phases_can_be_configured_as_iterating_phase_tables
    test_phases_can_be_configured_as_iterating_phases_with_sample_rate
    test_phases_can_be_configured_as_iterating_phases_with_minimum_rows
    test_table_with_calculations_must_also_contain_non_auto_capturing_phase_step
    test_table_with_durations_must_also_contain_non_auto_capturing_phase_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record uniq(@admin, false), uniq('1', false), open_phase_builder: true
  end

  def test_phases_can_be_configured_as_iterating_phase_tables
    @mc.phase_step.add_numeric
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    wait_until { @mc.phase_builder.phase_iterator_indicator_element.visible? }
  end

  def test_phases_can_be_configured_as_iterating_phases_with_sample_rate
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    @mc.phase_builder.iterations = 'g'
    assert @mc.phase_builder.inline_warning_element.visible?, 'Inline warning element was not visible'
    @mc.phase_builder.iterations = '20'
    assert !@mc.phase_builder.inline_warning_element.visible?, 'Inline warning element was visible'
    assert @mc.phase_builder.iterations.include?('20'), 'Iterations did not include 20'
    @mc.phase_builder.delete_phase_iterator
  end

  def test_phases_can_be_configured_as_iterating_phases_with_minimum_rows
    @mc.phase_step.add_numeric
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.minimum_rows_dropdown_item
    assert @mc.phase_builder.row_number_label_element.visible?, 'The row number label was not visible'
    @mc.phase_builder.minimum_rows = '10'
    assert @mc.phase_builder.phase_iterator_indicator_element.visible?, 'The phase iterator indicator was not visible.'
  end

  def test_table_with_calculations_must_also_contain_non_auto_capturing_phase_step
    add_new_table_phase 2
    @mc.phase_step.add_calculation_step warning: true
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 1
    @mc.phase_step.calculation_step.add_data_step '#'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_table_with_durations_must_also_contain_non_auto_capturing_phase_step
    add_new_table_phase 3
    @mc.phase_step.add_duration_step warning: true
    @mc.phase_step.add_date_step
    @mc.phase_step.add_date_step
    @mc.phase_step.add_duration_step
    assert @mc.phase_step.duration_step.data_step_is_available?('1.1.3.1'), 'Duration step modal did not successfully display.'
  end

  private

  def add_new_table_phase phase_number
    @mc.phase_builder.back
    @mc.structure_builder.phase_level.add_unit set_name: "Phase #{phase_number}"
    @mc.structure_builder.phase_level.select_unit phase_number
    @mc.structure_builder.phase_level.settings phase_number
    @mc.structure_builder.phase_level.open_phase_builder phase_number
    @mc.phase_builder.phase_iterator
  end
end
