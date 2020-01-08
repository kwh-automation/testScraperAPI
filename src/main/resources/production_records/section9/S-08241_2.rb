require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-08241_2_', false)
    @product_id = uniq('1', false)
    @lot_number = uniq('')
    @email_address = 'admin_user@mastercontrol.com'
    @subject = "Limit Notification on Product Name: #{@product_name}, Lot #: #{@lot_number}, Step: 1.1.1.1 - Numeric Step 1"

    pre_test
    test_execution_of_numeric_limits_notification
    test_email_was_sent_for_numeric_limits_notification
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.give_user_an_email_address @admin, @email_address
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true

    # Create mbr
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.numeric_data.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum '0'
    @mc.modalgeneralnumericlimits.set_maximum '100'
    @mc.modalgeneralnumericlimits.enable_notify
    @mc.modalgeneralnumericlimits.limit_notification_roles_select 'FT_ADMIN'
    @mc.modalgeneralnumericlimits.limit_notification_roles_toggle
    @mc.wait_for_video
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.back
  end

  def test_execution_of_numeric_limits_notification
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_first 'phase', @lot_number
    @mc.phase.phase_steps[0].set_value '101'
    @mc.phase.phase_steps[0].blur

    assert @mc.phase.phase_steps[0].captured_value == '101'
  end

  def test_email_was_sent_for_numeric_limits_notification
    assert @mc.do.check_email? @email_address, subject: @subject
  end
end
