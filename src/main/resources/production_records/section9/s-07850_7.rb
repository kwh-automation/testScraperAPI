# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('numeric_limts_')
    @product_id = uniq('NL_')
    @lot_number = uniq('')
    @master_batch_record = "#{@product_id} #{@product_name}"

    pre_test
    test_warn_users_when_numeric_input_is_outside_limits
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.numeric_data.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum '1'
    @mc.modalgeneralnumericlimits.set_maximum '20'

    wait_until { @mc.modalgeneralnumericlimits.is_modal_loaded? }

    @mc.modalgeneralnumericlimits.enable_warn
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.back
  end

  def test_warn_users_when_numeric_input_is_outside_limits
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record @master_batch_record, @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_value '30'
    @mc.phase.phase_steps[0].blur wait_for_completion: false
    assert @mc.phase.phase_steps[0].outside_the_specified_limits?
    @mc.refresh
    wait_until { @mc.phase.phase_steps[0].date != "" }
    assert @mc.phase.phase_steps[0].outside_the_specified_limits?
  end
end
