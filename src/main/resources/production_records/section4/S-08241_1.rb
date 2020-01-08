require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-08241_1_', false)
    @product_id = uniq('1', false)
    @email_address = 'admin_user@mastercontrol.com'

    pre_test
    test_building_numeric_limits_notification
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.give_user_an_email_address @admin, @email_address
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_building_numeric_limits_notification
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.numeric_data.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum '0'
    @mc.modalgeneralnumericlimits.set_maximum '100'
    @mc.modalgeneralnumericlimits.enable_notify
    @mc.modalgeneralnumericlimits.limit_notification_roles_select 'FT_ADMIN'
    @mc.modalgeneralnumericlimits.limit_notification_roles_toggle

    assert !@mc.error.displayed?

    @mc.wait_for_video
    @mc.modalgeneralnumericlimits.save_limit
  end
end
