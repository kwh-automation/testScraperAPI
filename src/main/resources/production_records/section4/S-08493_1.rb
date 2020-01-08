require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04501_", false)
    @product_id = uniq("1", false)

    pre_test
    test_add_field_entry_limits_property_to_calculation_step
    test_additional_field_entry_limits_can_be_added_to_a_calculation_step
    test_add_third_limit_to_calculation_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block "1", text:"Numeric Step 1"
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_add_field_entry_limits_property_to_calculation_step
    @mc.phase_step.calculation_step.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum "1"
    @mc.modalgeneralnumericlimits.set_maximum "20"
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.limit_container_element.visible?
    assert @mc.phase_step.calculation_step.min_limit(1)
  end

  def test_additional_field_entry_limits_can_be_added_to_a_calculation_step
    wait_until{@mc.phase_step.calculation_step.physical_limit_group_exists?}
    @mc.phase_step.calculation_step.limit_add
    assert @mc.phase_step.calculation_step.limit_add_element.visible?
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_minimum "5"
    @mc.modalgeneralnumericlimits.set_maximum "15"
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.calculation_step.min_limit(2)
  end

  def test_add_third_limit_to_calculation_step
    @mc.phase_step.calculation_step.limit_add
    wait_until{@mc.modalgeneralnumericlimits.is_modal_loaded?}
    @mc.modalgeneralnumericlimits.set_minimum "7"
    @mc.modalgeneralnumericlimits.set_maximum "10"
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.calculation_step.min_limit(3)
    assert !@mc.phase_step.calculation_step.limit_add_element.visible?,
           "The button for adding a fourth limit is visible. Only 3 limits should be able to be added."
  end
end
