require "mastercontrol-test-suite"

class ProductionRecordsFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq("Multi-Select_", false)
    @option1 = uniq("Option1_")
    @option2 = uniq("Option2_")
    @option3 = uniq("Option3_")

    pre_test
    test_verifying_multi_select_is_disabled_by_default
    test_enabling_multi_select
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
  end 

  def test_verifying_multi_select_is_disabled_by_default
    assert !(@mc.phase_step.multiple_choice_step.multi_select_status_element.attribute('checked') == "true")
    @mc.wait_for_video
  end

  def test_enabling_multi_select
    @mc.phase_step.multiple_choice_step.enable_multi_select
    assert (@mc.phase_step.multiple_choice_step.multi_select_status_element.attribute('checked') == "true")
    @mc.wait_for_video
  end

end