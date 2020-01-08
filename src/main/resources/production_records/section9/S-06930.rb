require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_selecting_pass
    test_users_name_and_date_populates_after_select_pass
    test_selecting_fail
    test_users_name_and_date_populates_after_select_fail
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection

    mbr_json =
      PhaseFactory.phase_customizer()
        .with_phase_step(PassFailBuilder.new)
        .with_phase_step(PassFailBuilder.new)
        .build_single_level_master_batch_record

    @test_environment =
      EbrTestEnvironmentBuilder.new
        .with_master_batch_record_json(mbr_json)
        .with_connection(connection)
        .build

    @mc.ebr_navigation.go_to_first('phase', @test_environment.master_batch_records[0].batch_records[0].lot_number)
    @pass_fail_step1 = @mc.phase.phase_steps[0]
    @pass_fail_step2 = @mc.phase.phase_steps[1]
  end

  def test_selecting_pass
    @pass_fail_step1.select_pass
    assert @pass_fail_step1.captured_value == 'Pass'
  end

  def test_users_name_and_date_populates_after_select_pass
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[0].date)
    step_performer_correct = @mc.phase.phase_steps[0].performer.include? @admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end

  def test_selecting_fail
    @pass_fail_step2.select_fail
    assert @pass_fail_step2.captured_value == 'Fail'
  end

  def test_users_name_and_date_populates_after_select_fail
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[1].date)
    step_performer_correct = @mc.phase.phase_steps[1].performer.include? @admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end
end