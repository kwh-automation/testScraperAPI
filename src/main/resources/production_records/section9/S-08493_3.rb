# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S08493_', false)
    @product_id = uniq('1', false)
    @lot_number = uniq('')
    @master_batch_record = "#{@product_id} #{@product_name}"

    pre_test
    test_warn_users_when_calculation_is_outside_limits
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
    @mc.phase_step.calculation_step.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum '1'
    @mc.modalgeneralnumericlimits.set_maximum '20'
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def test_warn_users_when_calculation_is_outside_limits
    @mc.do.create_batch_record @master_batch_record, @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_value '20'
    @mc.phase.phase_steps[0].blur wait_for_completion: false
    assert @mc.phase.phase_steps[1].outside_the_specified_limits?
  end
end
