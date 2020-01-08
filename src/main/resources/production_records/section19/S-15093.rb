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
    @required_parameter = ['parameter', 'required_input']
    @parameter_value1 = 'Title variation for text'
    @required_text = 'required'

    pre_test
    test_users_can_add_required_input_to_variation
    test_required_is_only_on_general_text
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @mt_name, @mt_id, default_lot_amount: '5', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step'
    @mc.phase_step.general_text.click_on_step_label 1
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = @required_text
    @mc.phase_step.general_text.save
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

  def test_users_can_add_required_input_to_variation
    @mc.variant_detail.create_variation @phase, 1, @required_parameter, new_parameter: @parameter_value1, required: @required_text
    @variant_id = @mc.url.split('/').last
    @order_label1 = "#{@phase}.1"
    assert ((@mc.variant_detail.get_required_input @order_label1) == @required_text), 'The required input variation for step 1.1.1.1 is not visible or not correct.'
  end

  def test_required_is_only_on_general_text
    @mc.variant_detail.create_variation @phase, 2, @parameter, new_parameter: @parameter_value1, save: false
    assert !@mc.variant_detail.required_input_checkbox_element.visible?
    @mc.variant_detail.save
    @mc.variant_detail.create_variation @phase, 3, @parameter, new_parameter: @parameter_value1, save: false
    assert !@mc.variant_detail.required_input_checkbox_element.visible?
    @mc.variant_detail.save
    @mc.variant_detail.create_variation @phase, 4, @parameter, new_parameter: @parameter_value1, save: false
    assert !@mc.variant_detail.required_input_checkbox_element.visible?
    @mc.variant_detail.save
  end

  def clean_up
    sql_query_br = "DELETE FROM [mfg_exe].[batch_records] WHERE variant_id ='#{@variant_id}'"
    @mc.do.run_query(sql_query_br, print_query: true)

    sql_query_rim = "DELETE FROM [mfg_cfg].[required_input_matches] WHERE variant_id ='#{@variant_id}'"
    @mc.do.run_query(sql_query_rim, print_query: true)

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