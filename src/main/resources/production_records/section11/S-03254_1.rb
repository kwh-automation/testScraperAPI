# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @correction_verifier = uniq('verifier')
    @connection = MCAPI.new
    @first_value = '5'
    @correction_note = 'I am a correction note.'

    pre_test

    test_that_change_reason_and_verify_display
    test_that_change_reason_is_required_if_present
    test_that_verification_is_required_if_present
    test_that_user_cannot_verify_own_correction
    test_verifying_correction_with_other_user
    test_adding_correction_note
  end

  def pre_test
    MCAPIs.create_user @correction_verifier, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees @correction_verifier, connection: @connection
    create_batch_record
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr_navigation.go_to_first 'phase', @lot_number
    @step_one = @mc.phase.phase_steps[0]
    @step_one.set_text @first_value
    @step_one.blur
    @step_one.start_correction
    wait_until { @step_one.correction.submit_correction_element.visible? }
  end

  def test_that_change_reason_and_verify_display
    @corrected_value = '6'
    wait_until { @step_one.correction.correction_started? }
    @step_one.set_text @corrected_value
    @step_one.correction.submit_correction
    wait_until { @step_one.correction.performer.include? '3254' }
    assert @step_one.correction.correction_reason
    assert @step_one.correction.correction_verify
  end

  def test_that_change_reason_is_required_if_present
    assert !@step_one.correction.can_finish_correction?
  end

  def test_that_verification_is_required_if_present
    @step_one.correction.correction_reason.select_correction_reason 1
    wait_until { @step_one.correction.correction_reason.performer.include? '3254' }
    assert !@step_one.correction.can_finish_correction?
  end

  def test_that_user_cannot_verify_own_correction
    @step_one.correction.correction_verify.username.send_keys @admin
    @step_one.correction.correction_verify.esignature.send_keys @admin_pass
    @step_one.correction.correction_verify.verifier_button.click
    assert @step_one.correction.already_entered_data?
  end

  def test_verifying_correction_with_other_user
    @step_one.correction.correction_verify.autocomplete @correction_verifier
    assert @step_one.correction.correction_verify.performer.include? 'verifier'
  end

  def test_adding_correction_note
    @step_one.correction.correction_notes.add
    @step_one.correction.correction_notes.set_text @correction_note
    @step_one.correction.correction_notes.save
    assert @step_one.correction.correction_notes.captured_notes.include? @correction_note
  end

  private

  def create_batch_record
    mbr_json = PhaseFactory.phase_customizer
                           .with_phase_step(GeneralTextBuilder.new
                                        .with_title('General Text with correction')
                                        .with_correction_configuration(CorrectionConfigurationBuilder.new
                                                                           .with_notes
                                                                           .with_reasons
                                                                           .with_verification
                                                                           .build))
                           .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_master_batch_record_json(mbr_json)
                                                 .with_lot_number(uniq(env['test_file_name']))
                                                 .with_unit_procedure_count(1)
                                                 .with_operation_count(1)
                                                 .with_phase_count(2)
                                                 .with_connection(@connection)
                                                 .build

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end
end
