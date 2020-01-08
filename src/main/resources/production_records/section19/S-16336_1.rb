require "mastercontrol-test-suite"

class Variants < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @prod_id = uniq('1', false)
    @prod_name = uniq('s16336_', false)
    @count_phase = 1
    @count_variation = 1
    @lot_number = uniq('Lot', false)
    @product_id1 = uniq('variant_id1_')
    @variant_title1 = uniq('variant_title1_')
    @variant_title_no_uniq = 'variant_title1_'
    @template = "#{@prod_id} #{@prod_name}"
    @phase = '1.1.1'
    @text_parameter = ['parameter', 'required_input']
    @numeric_parameter = ['parameter', 'numeric_limits']
    @general_text = 'General Text Step'
    @numeric_text = 'Numeric Step'
    @parameter_value1 = 'Title general text'
    @parameter_value2 = 'Title numeric'
    @parameter_value3 = 'Variation general text'
    @parameter_value4 = 'Variation numeric'
    @required_text = 'Required'
    @limits1 = [1,10]
    @limits2 = [2,9]
    @parameter_assert = 'Parameters are not correct'
    @na = ['na']

    pre_test
    test_user_confirm_edit_for_in_process_production_records
    test_edit_to_variations_updates_in_process_production_records
    test_deletion_of_variation_updates_in_process_production_records
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @prod_name, @prod_id, phase_count: 1, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count_phase, text: @general_text
    @count_phase += 1
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block @count_phase, text: @numeric_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @prod_name, @prod_id
    @mc.do.create_variant @variant_title1, @product_id1, parent_template: @template
    @mc.variant_detail.create_variation @phase, @count_variation, @text_parameter, new_parameter: @parameter_value1, required: @required_text, displayed: true
    @count_variation += 1
    @variant_id = @mc.url.split('/').last
    @mc.variant_detail.create_variation @phase, @count_variation, @numeric_parameter, new_parameter: @parameter_value2, new_limits: @limits1
    @mc.do.create_batch_record "#{@product_id1} #{@variant_title1}", @lot_number
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    assert !(@mc.phase.phase_steps[1].not_applicable_available?)
    assert ((@mc.phase.phase_steps[0].required_input_matches_message? "Value to be matched: #{@required_text}") == true), 'Required input message is not there'
    assert (@mc.phase.phase_steps[1].lower_limit == @limits1[0]), 'Lower limits is not correct'
    assert (@mc.phase.phase_steps[1].upper_limit == @limits1[1]), 'Upper limit is not correct'
  end

  def test_user_confirm_edit_for_in_process_production_records
    @mc.go_to.ebr.variant_view_all
    @mc.variant_list.filter_for variant_name: @variant_title1, variant_id: @product_id1
    @mc.variant_list.actions_edit_variant @product_id1
    @mc.variant_detail.edit_variation '1.1.1.1', varying_properties: @na, new_parameter: @parameter_value3, save: false, new_na: 'on'
    @mc.variant_detail.toggle_display_require_input
    @mc.variant_detail.save
    warning_drawer_continue
    @mc.variant_detail.edit_variation '1.1.1.2', varying_properties: @na, new_parameter: @parameter_value4, save: false, new_na: 'on'
    @mc.variant_detail.edit_limit_variation '1'
    @mc.modalgeneralnumericlimits.set_minimum @limits2[0]
    @mc.modalgeneralnumericlimits.set_maximum @limits2[1]
    @mc.modalgeneralnumericlimits.enable_warn
    @mc.modalgeneralnumericlimits.save_limit
    @mc.variant_detail.save
    warning_drawer_continue
  end

  def test_edit_to_variations_updates_in_process_production_records
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    assert ((@mc.phase.phase_steps[0].required_input_matches_message? "Value to be matched: #{@required_text}") != true), 'Required input message should not be there'
    assert (@mc.phase.phase_steps[0].phase_step_title.include? @parameter_value3), @parameter_assert
    assert (@mc.phase.phase_steps[1].phase_step_title.include? @parameter_value4), @parameter_assert
    assert (@mc.phase.phase_steps[1].lower_limit == @limits2[0]), 'Lower limits is not correct'
    assert (@mc.phase.phase_steps[1].upper_limit == @limits2[1]), 'Upper limit is not correct'
    assert (@mc.phase.phase_steps[1].not_applicable_available?)
  end

  def test_deletion_of_variation_updates_in_process_production_records
    @mc.go_to.ebr.variant_view_all
    @mc.variant_list.filter_for variant_name: @variant_title1, variant_id: @product_id1
    @mc.variant_list.actions_edit_variant @product_id1
    @mc.variant_detail.delete_variation '1.1.1.1'
    warning_drawer_continue
    @mc.variant_detail.delete_variation '1.1.1.2'
    warning_drawer_continue
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    assert (@mc.phase.phase_steps[0].phase_step_title.include? @general_text), @parameter_assert
    assert (@mc.phase.phase_steps[1].phase_step_title.include? @numeric_text), @parameter_assert
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

    sql_query_limit = "DELETE FROM [mfg_cfg].[required_input_matches] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_limit, print_query: true)

    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@variant_title_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end

  private
  def warning_drawer_continue
    wait_until{ @mc.variant_detail.in_process_warning_drawer_continue_element.visible? }
    assert @mc.variant_detail.in_process_documents(@lot_number).include? @lot_number
    @mc.variant_detail.in_process_warning_drawer_continue
  end
end