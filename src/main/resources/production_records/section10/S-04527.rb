# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @connection = MCAPI.new

    pre_test
    test_that_unit_of_measure_label_displays
    test_that_range_displays_when_configured_to_display
    test_exceeding_physical_limit_does_not_save_data
    test_that_phase_cannot_be_completed_until_valid_data_entered_in_phase_steps
    test_triggering_reject_action_on_physical_limit
  end

  def pre_test
    create_batch_record
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @phase_one = @mc.phase.phase_steps[0]
  end

  def test_that_unit_of_measure_label_displays
    assert @phase_one.unit_of_measure == 'g'
  end

  def test_that_range_displays_when_configured_to_display
    assert @phase_one.limit_label == 'narrowest'
    assert !(@phase_one.limit_label.include? 'physical')
  end

  def test_exceeding_physical_limit_does_not_save_data
    @phase_one.set_value 11
    @phase_one.blur wait_for_completion: false
    wait_until(10) { @phase_one.out_of_specification? }
  end

  def test_that_phase_cannot_be_completed_until_valid_data_entered_in_phase_steps
    @phase_one.set_value ''
    @phase_one.blur wait_for_completion: false
    @mc.phase.completion._complete
    wait_until { @phase_one.required_field? }
  end

  def test_triggering_reject_action_on_physical_limit
    assert !@phase_one.correction.correction_started?
  end

  private

  def create_batch_record
    mbr_json = PhaseFactory.phase_customizer
                           .with_phase_step(GeneralNumericBuilder.new
                                        .with_unit_of_measure('g')
                                        .with_limit(GeneralNumericLimitBuilder.new
                                                        .with_label('physical')
                                                        .with_minimum_value(1)
                                                        .with_maximum_value(10)
                                                        .with_visibility(false)
                                                        .with_action('REJECT')
                                                        .build)
                            .with_limit(GeneralNumericLimitBuilder.new
                                            .with_label('narrowest')
                                            .with_minimum_value(5)
                                            .with_maximum_value(6)
                                            .with_action('WARN')
                                            .with_visibility(true)
                                            .build)
                            .with_correction_configuration(CorrectionConfigurationBuilder.new.build))
                           .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_connection(@connection)
                                                 .with_master_batch_record_json(mbr_json)
                                                 .build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end
end
