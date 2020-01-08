require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @password = env['password']
    @product_name = uniq('S-16882_1', false)
    @product_id = uniq('1', false)
    @limit1 = {'min' => 1, 'max' => 10}
    @limit2 = {'min' => 2, 'max' => 9}
    @limit3 = {'min' => 3, 'max' => 8}
    @limitedit = {'min' => 0, 'max' => 11}
    @min = 'min'
    @max = 'max'
    @label1 = 'limit 1'
    @label2 = 'limit 2'
    @label3 = 'limit 3'

    pre_test
    test_user_can_add_sum_limit_to_numeric
    test_user_can_edit_sum_limit_to_numeric
    test_user_can_delete_sum_limit_to_numeric
    test_user_can_add_only_three_agg_sum_limits_to_numeric
    test_user_can_add_sum_limit_to_calculation
    test_user_can_edit_sum_limit_to_calculation
    test_user_can_delete_sum_limit_to_calculation
    test_user_can_add_only_three_agg_sum_limits_to_calculation
  end

  def pre_test
    @mc.do.login @admin, @password, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_user_can_add_sum_limit_to_numeric
    @mc.phase_step.phase_iterator
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block '1', text: 'Numeric Step 1'
    add_sum_limit
  end

  def test_user_can_edit_sum_limit_to_numeric
    edit_limit
  end

  def test_user_can_delete_sum_limit_to_numeric
    @mc.phase_step.click_delete_sum_limit 1
    assert (!@mc.phase_step.sum_limit)
  end

  def test_user_can_add_only_three_agg_sum_limits_to_numeric
    max_sum_limits
  end

  def test_user_can_add_sum_limit_to_calculation
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
    add_sum_limit
  end

  def test_user_can_edit_sum_limit_to_calculation
    edit_limit
  end

  def test_user_can_delete_sum_limit_to_calculation
    @mc.phase_step.click_delete_sum_limit 1
    assert (!@mc.phase_step.sum_limit)
  end

  def test_user_can_add_only_three_agg_sum_limits_to_calculation
    max_sum_limits
  end

  private
  def add_sum_limit
    @mc.phase_step.numeric_data.enable_aggregation_types
    @mc.phase_step.numeric_data.choose_aggregation_type 'Sum'
    @mc.phase_step.enable_sum_limit
    @mc.modalgeneralnumericlimits.limit_label = @label1
    @mc.modalgeneralnumericlimits.set_minimum @limit1[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit1[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.wait_for_video
    @mc.phase_step.scroll_properties_down 400
    assert @mc.phase_step.numeric_data.limit_add_element.visible?,
          "Should be able to add a limit"
  end

  def max_sum_limits
    @mc.phase_step.enable_sum_limit
    @mc.modalgeneralnumericlimits.limit_label = @label1
    @mc.modalgeneralnumericlimits.set_minimum @limit1[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit1[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.numeric_data.limit_add
    @mc.modalgeneralnumericlimits.limit_label = @label2
    @mc.modalgeneralnumericlimits.set_minimum @limit2[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit2[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.numeric_data.limit_add
    @mc.modalgeneralnumericlimits.limit_label = @label3
    @mc.modalgeneralnumericlimits.set_minimum @limit3[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit3[@max]
    @mc.modalgeneralnumericlimits.save_limit
    assert !@mc.phase_step.numeric_data.limit_add_element.visible?,
           "The button for adding a fourth limit is visible. Only 3 limits should be able to be added."
    @mc.phase_step.scroll_properties_down 400
  end

  def edit_limit
    @mc.phase_step.click_edit_sum_limit 1
    @mc.modalgeneralnumericlimits.set_minimum @limitedit[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limitedit[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.wait_for_video
    assert (@mc.phase_step.minimum_sum_limit(1) == @limitedit[@min].to_s)
    assert (@mc.phase_step.maximum_sum_limit(1) == @limitedit[@max].to_s)
  end
end