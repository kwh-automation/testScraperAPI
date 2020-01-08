require "mastercontrol-test-suite"

class ProductionRecordsFRS < MCValidationTest
# 10.12 Multi-Select
# 10.12.1 When a Multiple Choice data type is used, a user can enable the selection of more than one of the input entries. --> s-10846_2

# 10.12.2 The user must select "Submit" to capture the data. --> s-10846_2
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq("Multi-Select_", false)
    @option1 = uniq("Option1_")
    @option2 = uniq("Option2_")
    @option3 = uniq("Option3_")
    @master_batch_record = @master_template + " " + @master_template
    @lot_number = uniq("multi_select_")

    pre_test
    test_verifying_multiple_items_can_be_selected_with_multi_select_enabled
    test_verifing_submit_must_be_clicked_to_capture_the_selections
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @master_template, @master_template, open_phase_builder:true
    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 0, @option1
    @mc.phase_step.multiple_choice_step.add_multiple_choice_value
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 1, @option2
    @mc.phase_step.multiple_choice_step.add_multiple_choice_value
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 2, @option3
    @mc.phase_step.multiple_choice_step.enable_multi_select
    assert (@mc.phase_step.multiple_choice_step.multi_select_status_element.attribute('checked') == "true")
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @master_template
    @mc.do.create_batch_record @master_batch_record, @lot_number
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
  end

  def test_verifying_multiple_items_can_be_selected_with_multi_select_enabled
    @mc.phase.phase_steps[0].select_option 1
    @mc.phase.phase_steps[0].select_option 2
  end

  def test_verifing_submit_must_be_clicked_to_capture_the_selections
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    @mc.phase.phase_steps[0].select_option 1
    @mc.phase.phase_steps[0].select_option 3

    @mc.phase.phase_steps[0].submit

    assert @mc.phase.phase_steps[0].captured_value.include? @option1
    assert @mc.phase.phase_steps[0].captured_value.include? @option3
  end

end