require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_multiple_options_exist
    test_that_selection_saves
    test_that_only_one_option_can_be_selected
    test_that_step_completion_performer_populates_after_click
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection
    @option_1 = uniq('option_1')
    @option_2 = uniq('option_2')
    @option_3 = uniq('option_3')

    mbr_json =
      PhaseFactory.phase_customizer()
        .with_phase_step(MultipleChoiceBuilder.new.with_option(@option_1).with_option(@option_2).with_option(@option_3))
        .build_single_level_master_batch_record

    @test_environment =
      EbrTestEnvironmentBuilder.new
        .with_master_batch_record_json(mbr_json)
        .with_connection(connection)
        .build

    @mc.ebr_navigation.go_to_first('phase', @test_environment.master_batch_records[0].batch_records[0].lot_number)
    @multi_choice_step = @mc.phase.phase_steps[0]
  end

  def test_multiple_options_exist
    assert @multi_choice_step.option_labels[0] == @option_1
    assert @multi_choice_step.option_labels[1] == @option_2
    assert @multi_choice_step.option_labels[2] == @option_3
  end

  def test_that_selection_saves
    @multi_choice_step.select_option 2
    assert @multi_choice_step.captured_value[0] == @option_2
  end

  def test_that_only_one_option_can_be_selected
    @multi_choice_step.select_option 1
    assert @multi_choice_step.captured_value[0] != @option_1
  end

  def test_that_step_completion_performer_populates_after_click
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[0].date)
    step_performer_correct = @multi_choice_step.performer.include?@admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end
end