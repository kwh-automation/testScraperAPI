require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @connection = MCAPI.new

    pre_test

    test_that_user_can_correct_phase_step_data
    test_that_users_cannot_advance_phase_step_without_completing_correction
    test_that_new_value_is_required_to_save_the_correction
    test_viewing_correction_play_by_play_after
  end

  def pre_test
    @first_value = "5"

    @mc.do.login @admin, @admin_pass
    MCAPIs.approve_trainees [@admin], connection: @connection

    mbr_json = PhaseFactory.phase_customizer().with_phase_step(GeneralTextBuilder.new.
        with_title("General Text with correction").
        with_correction_configuration(CorrectionConfigurationBuilder.new.
            with_notes.
            build)
        ).
    build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.
        with_master_batch_record_json(mbr_json).
        with_lot_number(uniq("#{env['test_file_name']}")).
        with_unit_procedure_count(1).
        with_operation_count(1).
        with_phase_count(2).
        with_connection(@connection).
        build

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @mc.ebr_navigation.go_to_first "phase", @lot_number
    @phase_step = @mc.phase.phase_steps[0]
    @phase_step.set_text @first_value
    @phase_step.blur
    @first_value_timestamp = @phase_step.date
  end

  def test_that_user_can_correct_phase_step_data
    @phase_step.start_correction
    assert @phase_step.correction.correction_started?, "The correction did not launch."
  end

  def test_that_users_cannot_advance_phase_step_without_completing_correction
    @mc.phase.completion._complete
    assert @phase_step.correction.correction_started?, "The phase advanced while the correction was unfinished."
  end

  def test_that_new_value_is_required_to_save_the_correction
    @phase_step.correction.submit_correction
    assert @phase_step.correction.correction_started?, "The correction completed without a new value."
    submit_proper_correction
  end

  def test_viewing_correction_play_by_play_after
    @phase_step.show_corrections
    sleep 1
    assert (@phase_step.play_by_play.play_by_play_data[0].include? "started")
    assert (@phase_step.play_by_play.play_by_play_data[1].include? "\"#{@first_value}\" was entered by #{@admin} #{@admin} on #{@first_value_timestamp}. It was changed to \"#{@corrected_value}\".") 
    assert (@phase_step.play_by_play.play_by_play_data[2].include? "completed")
  end

  private
  def submit_proper_correction
    @corrected_value = "6"
    @phase_step.set_text @corrected_value
    @phase_step.correction.submit_correction
    wait_until{@phase_step.correction.performer.include? "3254"}
    @phase_step.correction.finish_correction
  end
end