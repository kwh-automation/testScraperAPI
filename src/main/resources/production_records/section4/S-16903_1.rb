require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S16903_1_", false)
    @product_id = uniq("1", false)

    pre_test
    test_pass_fail_phase_step_can_be_configured_to_use_yes_no
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
  end

  def test_pass_fail_phase_step_can_be_configured_to_use_yes_no
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_pass_fail_as_yes_no
    @mc.phase_step.pass_fail_step.enable_pass_fail_limits
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_label "Repeat Operation"
    @mc.modalgeneralnumericlimits.enable_repeat_operation
    @mc.modalgeneralnumericlimits.limit_fail_element.click
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.limit_container_element.attribute("innerText").include? "No"
  end

end
