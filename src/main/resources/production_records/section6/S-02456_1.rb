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
    @connection = MCAPI.new

    pre_test

    test_that_user_cannot_witness_own_data_capture
    test_that_verify_cannot_be_performed_before_witness_when_both_configured
    test_witnessing_data_capture
    test_that_user_cannot_verify_own_data_capture
    test_that_witness_cannot_also_verify_data_capture
    test_verifying_data_capture
  end

  def pre_test
    @mc.do.login @admin, @admin_pass
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@admin, @quality, @supervisor], connection: @connection

    switch_browser_context @supervisor
    @mc.do.login @supervisor, @pass
    @option_1 = "pick me"
    @option_2 = "no pick me!"

    mbr_json = PhaseFactory.phase_customizer().with_phase_step(MultipleChoiceBuilder.new.with_option(@option_1).with_option(@option_2).with_witness().with_verification().with_title("Witness/Verification Mutliple Choice Multiuser Test")).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(@connection).with_master_batch_record_json(mbr_json).with_batch_records_per_master_batch_record(1).with_lot_number(uniq("Lot")).build

    @batch_record = @test_environment.master_batch_records[0].batch_records[0]
    navigate_to_first "phase", @batch_record.lot_number

    switch_browser_context @admin
    navigate_to_first "phase", @batch_record.lot_number
    @mc.phase.phase_steps[0].select_option 2
    wait_until(20){@mc.phase.phase_steps[0].captured_value}
  end

  def test_that_user_cannot_witness_own_data_capture
    @mc.phase.phase_steps[0].witness.username.send_keys @admin
    @mc.phase.phase_steps[0].witness.esignature.send_keys @esig
    @mc.phase.phase_steps[0].witness.submit
    wait_until{@mc.phase.phase_steps[0].witness.performer != ""}
    assert @mc.phase.phase_steps[0].phase_step_indicator_has "error"
    sleep 1
  end

  def test_that_verify_cannot_be_performed_before_witness_when_both_configured
    assert !@mc.phase.phase_steps[0].verification.input_enabled?
  end

  def test_witnessing_data_capture
    switch_browser_context @quality
    @mc.do.login @quality, @pass
    navigate_to_first "phase", @batch_record.lot_number
    @mc.phase.phase_steps[0].witness.autocomplete @quality

    switch_browser_context @supervisor
    assert @mc.phase.phase_steps[0].phase_step_indicator_has "warning"
    assert @mc.phase.phase_steps[0].witness.performer? @quality
  end

  def test_that_user_cannot_verify_own_data_capture
    switch_browser_context @admin
    @mc.phase.phase_steps[0].verification.username.send_keys @admin
    @mc.phase.phase_steps[0].verification.esignature.send_keys @esig
    @mc.phase.phase_steps[0].verification.submit
    wait_until{@mc.phase.phase_steps[0].witness.help_block_message != ""}
    assert @mc.phase.phase_steps[0].verification.is_user_not_unique?
    sleep 1
  end

  def test_that_witness_cannot_also_verify_data_capture
    switch_browser_context @quality
    @mc.phase.phase_steps[0].verification.username.send_keys @quality
    @mc.phase.phase_steps[0].verification.esignature.send_keys @esig
    @mc.phase.phase_steps[0].verification.submit
    wait_until{@mc.phase.phase_steps[0].witness.help_block_message != ""}
    assert @mc.phase.phase_steps[0].verification.is_user_not_unique?
    sleep 1
  end

  def test_verifying_data_capture
    switch_browser_context @supervisor
    @mc.phase.phase_steps[0].verification.autocomplete @supervisor
    switch_browser_context @quality
    wait_until{@mc.phase.phase_steps[0].phase_step_indicator_has "warning"}
    assert @mc.phase.phase_steps[0].phase_step_indicator_has "warning"
    assert @mc.phase.phase_steps[0].verification.performer?@supervisor
  end

private
  def navigate_to_first level, lot_number
    @mc.go_to.ebr
    @mc.ebr_navigation.go_to_first level, lot_number
  end
end
