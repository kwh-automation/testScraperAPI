# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']

    pre_test
    test_no_duration_phase_step_can_be_added_to_a_phase_belonging_to_a_repeating_operation
    test_no_calculation_can_reference_a_phase_step_belonging_to_a_repeating_operation
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record uniq(@admin, false), uniq('1', false)
  end

  def test_no_duration_phase_step_can_be_added_to_a_phase_belonging_to_a_repeating_operation
    open_phase_one
    @mc.phase_step.add_date_step
    @mc.phase_step.add_date_step
    @mc.phase_step.add_duration_step warning: true
  end

  def test_no_calculation_can_reference_a_phase_step_belonging_to_a_repeating_operation
    @mc.phase_step.add_numeric
    @mc.phase_step.back
    @mc.operation_level.add_unit set_name: 'Non-Repeatable'
    @mc.phase_level.add_unit set_name: 'New Phase'
    @mc.phase_level.configure_phase 1
    @mc.phase_step.add_calculation_step
    assert !(@mc.phase_step.calculation_step.phase_available_to_choose? '1.1.1 - Phase 1'),
           'Numeric Value from Phase in a Repeating Operation listed in selectable calculation options.'
    assert_equals @mc.phase_step.data_step_header_elements.count, 0
  end

  private

  def open_phase_one
    @mc.operation_level.select_unit 1
    @mc.operation_level.settings 1
    @mc.operation_level.repeatable_element.on
    @mc.operation_level.save
    @mc.phase_level.select_unit 1
    @mc.phase_level.settings 1
    @mc.phase_level.open_phase_builder 1
  end
end
