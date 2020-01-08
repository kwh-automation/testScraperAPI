require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S15808_1_", false)
    @product_id = uniq("1", false)

    pre_test
    test_action_can_be_configured_on_a_pass_fail_phase_step
    test_additional_action_can_be_configured_on_a_pass_fail_phase_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
  end

  def test_action_can_be_configured_on_a_pass_fail_phase_step
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_pass_fail_limits
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_label "Repeat Operation"
    @mc.modalgeneralnumericlimits.enable_repeat_operation
    @mc.modalgeneralnumericlimits.limit_fail_element.click
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.limit_container_element.attribute("innerText").include? "Repeat Operation"
  end

  def test_additional_action_can_be_configured_on_a_pass_fail_phase_step
    wait_until{@mc.phase_step.pass_fail_step.physical_limit_group_exists?}
    @mc.phase_step.pass_fail_step.limit_add
    assert @mc.phase_step.pass_fail_step.limit_add_element.visible?
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_label "Warn"
    @mc.modalgeneralnumericlimits.enable_warn
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.limit_container_element.attribute("innerText").include? "Warn"
    @mc.phase_step.pass_fail_step.click_edit_action 1
    assert !@mc.modalgeneralnumericlimits.limit_pass_element.visible?
    assert @mc.modalgeneralnumericlimits.limit_fail_element.visible?
  end

end
