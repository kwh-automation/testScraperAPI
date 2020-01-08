require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq('pass_fail_')
    @mbr_id = uniq('actions_on_')

    pre_test
    test_user_can_assign_limit_actions_to_pass_fail
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection
    @mc.do.create_master_batch_record @mbr_name, @mbr_id
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
  end

  def test_user_can_assign_limit_actions_to_pass_fail
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_pass_fail_limits
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_label "conditional action"
    @mc.modalgeneralnumericlimits.enable_warn
    @mc.modalgeneralnumericlimits.enable_repeat_operation
    @mc.modalgeneralnumericlimits.limit_fail_element.click
    @mc.modalgeneralnumericlimits.save_limit
    assert (assert @mc.phase_step.limit_container_element.visible?)
  end

end