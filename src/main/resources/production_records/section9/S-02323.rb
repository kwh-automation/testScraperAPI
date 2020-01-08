require "mastercontrol-test-suite"
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_completing_phase_step
    test_that_step_completion_performer_populates_after_click
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection

    mbr_json = PhaseFactory.phase_customizer().
                with_phase_step(StepCompletionBuilder.new.
                                  with_title("Step Completion Notifications Test")
                  ).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.
                with_master_batch_record_json(mbr_json).
                with_connection(connection).
                build

    batch_record = @test_environment.master_batch_records[0].batch_records[0]
    @mc.do.navigate_to_first "phase", batch_record.lot_number
  end

  def test_completing_phase_step
    @mc.phase.phase_steps[0].complete
    background_is_gray = @mc.phase.phase_steps[0].completed?
    assert background_is_gray
  end

  def test_that_step_completion_performer_populates_after_click
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[0].date)
    step_performer_correct = @mc.phase.phase_steps[0].performer.include? @admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end
end