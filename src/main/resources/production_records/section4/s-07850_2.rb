require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('numeric_limts_')
    @product_id = uniq('NL_')
    @master_batch_record = "#{@product_id} #{@product_name}"

    pre_test
    test_users_can_select_to_warn_users_if_outside_limits
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_users_can_select_to_warn_users_if_outside_limits
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.numeric_data.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum '1'
    @mc.modalgeneralnumericlimits.set_maximum '20'

    wait_until { @mc.modalgeneralnumericlimits.is_modal_loaded? }

    @mc.modalgeneralnumericlimits.enable_warn
    @mc.modalgeneralnumericlimits.save_limit

    assert @mc.phase_step.limit_container_element.attribute('innerText').include? 'Warn'
  end
end
