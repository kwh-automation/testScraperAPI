require "mastercontrol-test-suite"

class Variants < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_id = uniq('variant_id_')
    @variant_title = uniq('variant_title_')
    @title_no_uniq = uniq('variant_title_', false)
    @mt_name = uniq('mt_name_')
    @mt_id = uniq('mt_id_')
    @template = "#{@mt_id} #{@mt_name}"
    @connection = MCAPI.new
    @phase = '1.1.1'
    @parameter = ['parameter']
    @na = ['na']
    @limits = ['numeric_limits']
    @parameter_value1 = 'Title variation for text'
    @parameter_value2 = 'This is a different variation for text'
    @na_value = 'off'
    @limit_value = ['1', '10']

    pre_test
    test_user_can_create_variation_on_parameter
    test_user_can_create_variation_on_na
    test_user_can_create_variation_on_limits
    test_user_can_edit_variations
    test_numeric_limit_variations_only_on_numeric_type
    test_user_can_delete_variations
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @mt_name, @mt_id, default_lot_amount: '5', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step'
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block 2, text: 'Date Step'
    @mc.phase_step.add_date_time_step
    @mc.phase_step.date_time_step.add_text_block 3, text: 'Date Time Step'
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block 4, text: 'Numeric Data Step'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    MCAPIs.approve_MBR @mt_name, connection: @connection
    @mc.do.create_variant @variant_title, @product_id, parent_template: @template
  end

  def test_user_can_create_variation_on_parameter
    @mc.variant_detail.create_variation @phase, 1, @parameter, new_parameter: @parameter_value1
    @variant_id = @mc.url.split('/').last
    @order_label1 = "#{@phase}.1"
    assert (@mc.variant_detail.get_parameter_variation @order_label1) == @parameter_value1, 'The phase step title variation for step 1.1.1.1 is not visible or not correct.'
  end

  def test_user_can_create_variation_on_na
    @mc.variant_detail.create_variation @phase, 2, @na, new_na: @na_value
    @order_label2 = "#{@phase}.2"
    assert (@mc.variant_detail.get_na_variation @order_label2) == @na_value, 'The not applicable variation for step 1.1.1.2 is not visible or not correct.'
  end

  def test_user_can_create_variation_on_limits
    @mc.variant_detail.create_variation @phase, 4, @limits, new_limits: @limit_value
    @order_label4 = "#{@phase}.4"
    assert (@mc.variant_detail.get_limit_variation @order_label4) == 'on', 'The numeric limits variation for step 1.1.1.4 is not visible or not correct.'
  end

  def test_user_can_edit_variations
    @mc.variant_detail.edit_variation @order_label1, new_parameter: @parameter_value2
    assert (@mc.variant_detail.get_parameter_variation @order_label1) == @parameter_value2, 'The phase step title variation, after edit, for step 1.1.1.1 is not visible or not correct.'
  end

  def test_numeric_limit_variations_only_on_numeric_type
    @mc.variant_detail.add_variation
    @mc.variant_detail.select_phase @phase

    for index in 1..3
      @mc.variant_detail.select_phase_step @phase, index
      assert !@mc.variant_detail.numeric_limits_checkbox_element.visible?, 'The numeric limits checkbox is visible on a non-numeric phase step.'
    end

    @mc.variant_detail.select_phase_step @phase, 4
    assert @mc.variant_detail.numeric_limits_checkbox_element.visible?, 'The numeric limits checkbox is not visible on a numeric phase step.'
    wait_until{@mc.variant_detail.cancel_element.visible?}
    @mc.variant_detail.cancel
  end

  def test_user_can_delete_variations
    assert (@mc.variant_detail.variation_exists? @order_label1), "The variation for #{@order_label1} is not visible."
    @mc.variant_detail.delete_variation @order_label1
    assert (!@mc.variant_detail.variation_exists? @order_label1), "The variation for #{@order_label1} is visible."
  end

  def clean_up
    sql_query_br = "DELETE FROM [mfg_exe].[batch_records] WHERE variant_id ='#{@variant_id}'"
    @mc.do.run_query(sql_query_br, print_query: true)

    sql_query_title = "DELETE FROM [mfg_cfg].[variation_phase_step_title] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_title, print_query: true)

    sql_query_na = "DELETE FROM [mfg_cfg].[variation_phase_step_na] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_na, print_query: true)

    sql_query_limit = "DELETE FROM [mfg_cfg].[numeric_limits] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_limit, print_query: true)

    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@title_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end
end