require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @esig = env["admin_esig"]
    @pass = env["password"]
    @quality = uniq("Quality_")
    @supervisor = uniq("Super_")

    pre_test

    test_field_title_of_phase_step
    test_that_user_cannot_witness_own_step_completion
    test_that_witness_must_happen_before_verify_if_both_present
    test_successfully_witnessing_step_completion_with_other_user
    test_that_user_cannot_verify_own_step_completion
    test_that_same_user_cannot_witness_and_verify_on_same_step
    test_successfully_verifying_step_completion_with_third_user
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: connection
    MCAPIs.approve_trainees [@quality, @supervisor], connection: connection

    @phase_step_order_label = uniq('1.1.1.1')
    @phase_step_title = uniq('1622')

    mbr_json = PhaseFactory.phase_customizer().with_phase_step(StepCompletionBuilder.new.with_order_label(@phase_step_order_label).with_title(@phase_step_title).with_witness.with_verification).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(mbr_json).build

    @mc.ebr_navigation.go_to_first('phase', @test_environment.master_batch_records[0].batch_records[0].lot_number)
    @phase = @mc.phase.phase_steps[0]
  end

  def test_field_title_of_phase_step
    assert @phase.phase_step_title.include? @phase_step_order_label
    assert @phase.phase_step_title.include? @phase_step_title
  end

  def test_that_user_cannot_witness_own_step_completion
    @phase.complete
    wait_until {@phase.date != ""}
    @phase.witness.username.send_keys @admin
    @phase.witness.esignature.send_keys @esig
    @phase.witness.submit
    wait_until {@phase.witness.help_block_message != ""}
    assert @phase.witness.is_user_not_unique?
  end

  def test_that_witness_must_happen_before_verify_if_both_present
    assert !@phase.verification.input_enabled?
  end

  def test_successfully_witnessing_step_completion_with_other_user
    @phase.witness.autocomplete @quality
  end

  def test_that_user_cannot_verify_own_step_completion
    @phase.verification.username.send_keys @admin
    @phase.verification.esignature.send_keys @esig
    @phase.verification.submit
    wait_until {@phase.witness.help_block_message != ""}
    assert @phase.verification.is_user_not_unique?
  end

  def test_that_same_user_cannot_witness_and_verify_on_same_step
    @phase.verification.username.clear
    @phase.verification.esignature.clear
    @phase.verification.username.send_keys @quality
    @phase.verification.esignature.send_keys @esig
    @phase.verification.submit
    wait_until {@phase.witness.help_block_message != ""}
    assert @phase.verification.is_user_not_unique?
  end

  def test_successfully_verifying_step_completion_with_third_user
    @phase.verification.autocomplete @supervisor
    assert @phase.verification.performer? @supervisor
  end

end
