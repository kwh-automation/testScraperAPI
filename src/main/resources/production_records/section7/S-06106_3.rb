require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @esig = env["admin_esig"]
    @quality = uniq("Quality_")
    @supervisor = uniq("Super_")
    @connection = MCAPI.new

    pre_test

    test_that_phase_steps_must_be_completed_before_phase_can_be_completed
    test_that_phase_can_be_witnessed_and_verified
    test_that_witness_must_be_performed_first_when_both_options_present
    test_that_user_who_entered_data_cannot_witness_phase_completion
    test_that_user_who_entered_data_cannot_verify_phase_completion
    test_that_a_single_user_cannot_witness_and_verify_the_same_phase_completion
    test_that_independent_verifier_prevents_a_phase_step_verifier_from_also_verifying_phase_completion
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@quality, @supervisor], esig: env["admin_esig"], connection: @connection

    mbr_json = PhaseFactory.phase_customizer()
          .with_phase_step(StepCompletionBuilder.new.
              with_order_number(1)
          )
          .with_phase_step(StepCompletionBuilder.new.
              with_order_number(2)
              .with_verification
          )
          .with_witness
          .with_verification
          .with_unique_verifier
      .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_master_batch_record_json(mbr_json).with_connection(@connection).build

    @mc.ebr_navigation.go_to_first('phase', @test_environment.master_batch_records[0].batch_records[0].lot_number)
    @step_1 = @mc.phase.phase_steps[0]
    @step_2 = @mc.phase.phase_steps[1]
  end

  def test_that_phase_steps_must_be_completed_before_phase_can_be_completed
    @mc.phase.completion._complete
    wait_until{@mc.phase.phase_steps[0].required_field?}
    assert @step_2.required_field?
  end

  def test_that_phase_can_be_witnessed_and_verified
    assert @mc.phase.completion.witness != nil
    assert @mc.phase.completion.verification != nil
  end

  def test_that_witness_must_be_performed_first_when_both_options_present
    @step_1.complete
    wait_until{@step_1.completed?}
    @step_2.complete
    wait_until{@step_2.completed?}
    @step_2.verification.username.send_keys @supervisor
    @step_2.verification.esignature.send_keys @esig
    @step_2.verification.submit
    @mc.phase.completion.complete
    wait_until{@mc.phase.completion.date != ""}
    assert @mc.phase.completion.witness.enabled?
    assert !@mc.phase.completion.verification.enabled?
  end

  def test_that_user_who_entered_data_cannot_witness_phase_completion
    @mc.phase.completion.witness.username.send_keys @admin
    @mc.phase.completion.witness.esignature.send_keys @esig
    @mc.phase.completion.witness.submit
    wait_until{@mc.phase.completion.witness.is_user_not_unique?}
  end

  def test_that_user_who_entered_data_cannot_verify_phase_completion
    @mc.phase.completion.witness.username.clear
    @mc.phase.completion.witness.esignature.clear
    @mc.phase.completion.witness.username.send_keys @quality
    @mc.phase.completion.witness.esignature.send_keys @esig
    @mc.phase.completion.witness.submit
    wait_until{@mc.phase.completion.witness.displayed_date != ""}
    @mc.phase.completion.verification.username.send_keys @admin
    @mc.phase.completion.verification.esignature.send_keys @esig
    @mc.phase.completion.verification.submit
    wait_until{@mc.phase.completion.verification.is_user_not_unique?}
  end

  def test_that_a_single_user_cannot_witness_and_verify_the_same_phase_completion
    @mc.phase.completion.verification.username.clear
    @mc.phase.completion.verification.esignature.clear
    @mc.phase.completion.verification.username.send_keys @quality
    @mc.phase.completion.verification.esignature.send_keys @esig
    @mc.phase.completion.verification.submit
    wait_until{@mc.phase.completion.verification.is_user_not_unique?}
  end

  def test_that_independent_verifier_prevents_a_phase_step_verifier_from_also_verifying_phase_completion
    @mc.phase.completion.verification.username.clear
    @mc.phase.completion.verification.esignature.clear
    @mc.phase.completion.verification.username.send_keys @supervisor
    @mc.phase.completion.verification.esignature.send_keys @esig
    @mc.phase.completion.verification.submit
    wait_until{@mc.phase.completion.verification.is_user_not_unique?}
  end

end
