# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @connection = MCAPI.new

    pre_test
    test_that_numeric_field_only_accepts_numbers
    test_saving_entry_when_data_field_loses_focus
    test_capturing_user_name_and_timestamp_when_data_is_saved
    test_accepting_negative_numeric_values_in_general_numeric
  end

  def pre_test
    create_batch_record
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @first_general_numeric = @mc.phase.phase_steps[0]
  end

  def test_that_numeric_field_only_accepts_numbers
    @first_general_numeric.set_value 'non-numeric-value'
    @first_general_numeric.blur wait_for_completion: false
    wait_until { @first_general_numeric.out_of_specification? }
    @numeric_test_value = '12333'
    @first_general_numeric.set_value @numeric_test_value
  end

  def test_saving_entry_when_data_field_loses_focus
    @first_general_numeric.blur
    wait_until { @first_general_numeric.captured_value == @numeric_test_value }
  end

  def test_capturing_user_name_and_timestamp_when_data_is_saved
    assert @first_general_numeric.performer.include?(@admin.downcase)
    assert @mc.do.check_time(@first_general_numeric.date)
  end

  def test_accepting_negative_numeric_values_in_general_numeric
    negative_numeric_test_value = '-12333'
    @second_general_numeric = @mc.phase.phase_steps[1]
    @second_general_numeric.set_value negative_numeric_test_value
    @second_general_numeric.blur
    assert @second_general_numeric.captured_value == negative_numeric_test_value
  end

  private

  def create_batch_record
    custom_phase =
      PhaseFactory.phase_customizer
                  .with_phase_step(GeneralNumericBuilder.new)
                  .with_phase_step(GeneralNumericBuilder.new)
                  .build_single_level_master_batch_record
    @test_environment =
      EbrTestEnvironmentBuilder.new
                               .with_lot_number(uniq('1717'))
                               .with_master_batch_record_json(custom_phase)
                               .with_connection(@connection)
                               .build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end
end
