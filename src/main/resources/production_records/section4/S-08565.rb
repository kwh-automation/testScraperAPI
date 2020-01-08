require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('calculation_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')

    pre_test
    test_configuring_precision_between_0_and_4
    test_selecting_standard_rounding_or_truncate

  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_numeric
  end

  def test_configuring_precision_between_0_and_4
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
    @mc.phase_step.calculation_step.enable_rounding_precision
    sleep 2
    @mc.phase_step.calculation_step.slider_value_3_element.click
    sleep 2
    @mc.phase_step.calculation_step.slider_value_2_element.click
    sleep 2
    @mc.phase_step.calculation_step.slider_value_1_element.click
    sleep 2
    @mc.phase_step.calculation_step.slider_value_0_element.click
  end

  def test_selecting_standard_rounding_or_truncate
    @mc.phase_step.calculation_step.standard_rounding
    sleep 2
    @mc.phase_step.calculation_step.truncate
  end

end