require "mastercontrol-test-suite"

class Variants < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_id1 = uniq('variant_id1_')
    @variant_title1 = uniq('variant_title1_')
    @product_id2 = uniq('variant_id2_')
    @variant_title2 = uniq('variant_title2_')
    @variant_title2_no_uniq = 'variant_title2_'
    @variant_qty1 = '1'
    @variant_qty2 = '2'
    @mt_name = uniq('mt_name_')
    @mt_id = uniq('mt_id_')
    @template = "#{@mt_id} #{@mt_name}"
    @connection = MCAPI.new
    @application = "Production Records"
    @title_no_uniq = uniq('variant_title2_', false)
    @variation_na1 = 'on'
    @variation_na2 = 'off'
    @variation_na1_aud = 'True'
    @variation_na2_aud = 'False'
    @variation_rim1 = uniq('req text_')
    @variation_rim2 = uniq('modified req text_')
    @parameter_value1 = uniq('param1_')
    @parameter_value2 = uniq('param2_')
    @variation_num1_range = [1,10]
    @variation_num2_range = [2,9]
    @phase = '1.1.1'

    pre_test
    test_creating_or_editing_variants_produces_audit_log_entries
    test_creating_or_editing_variations_produces_audit_log_entries
    test_revising_master_templates_produces_audit_log_entries_for_copied_variants
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @mt_name, @mt_id, default_lot_amount: '5', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step'
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block 2, text: 'Date Step'
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 3, text: 'General Text Step'
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block 4, text: 'Numeric Data Step'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    @mc.structure_builder.back
    @mc.master_batch_record_list.edit_master_batch_record @mt_id
    wait_until {@mc.structure_builder.back_element.visible? }
    @mt_db_id1 = @mc.url.split('/').last

    #create variant
    @mc.do.create_variant @variant_title1, @product_id1, parent_template: @template, qty: @variant_qty1
    @mc.variant_detail.edit_variant
    @mc.variant_modal.product_name = @variant_title2
    @mc.variant_modal.product_id = @product_id2
    @mc.variant_modal.default_qty = @variant_qty2
    @mc.variant_modal.save
    @variant_id1 = @mc.url.split('/').last

    #create variations
    @mc.variant_detail.create_variation @phase, 1, ['parameter'], new_parameter: @parameter_value1
    @order_label_param = "#{@phase}.1"
    assert (@mc.variant_detail.get_parameter_variation @order_label_param) == @parameter_value1, 'The phase step title variation for step 1.1.1.1 is not visible or not correct.'

    @mc.variant_detail.create_variation @phase, 2, ['na'], new_na: @variation_na1
    @order_label_na = "#{@phase}.2"
    assert (@mc.variant_detail.get_na_variation @order_label_na) == @variation_na1, 'The not applicable variation for step 1.1.1.2 is not visible or not correct.'

    @mc.variant_detail.create_variation @phase, 3, ['required_input'], required: @variation_rim1
    @order_label_rim = "#{@phase}.3"
    assert (@mc.variant_detail.get_required_input @order_label_rim) == @variation_rim1, 'The required input match variation for step 1.1.1.3 is not visible or not correct.'

    @mc.variant_detail.create_variation @phase, 4, ['numeric_limits'], new_limits: @variation_num1_range
    @order_label_num = "#{@phase}.4"

    #edit variations
    @mc.variant_detail.edit_variation @order_label_param, new_parameter: @parameter_value2, save: true
    @mc.variant_detail.edit_variation @order_label_na, new_na: @variation_na2, save: true
    @mc.variant_detail.edit_variation @order_label_rim, required: @variation_rim2, save: true, displayed: false
    @mc.variant_detail.edit_variation @order_label_num, save: false
    @mc.variant_detail.edit_limit_variation '1'
    @mc.modalgeneralnumericlimits.set_minimum @variation_num2_range[0]
    @mc.modalgeneralnumericlimits.set_maximum @variation_num2_range[1]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.variant_detail.save
  end

  def test_creating_or_editing_variants_produces_audit_log_entries
    @change_reason_create1 = "Created #{@product_id1} - #{@variant_title1} (#{@variant_id1})"
    @change_reason_edit = "Edited #{@product_id2} - #{@variant_title2} (#{@variant_id1})"

    @mc.do.search_audit_log @application, change_reason: @variant_id1, changes_by_user: @admin
    @mc.audit_log.multiple_changes_element.scroll_into_view

    assert @mc.audit_log.in_list? "Product Name", @variant_title1, @admin, change_reason: @change_reason_create1
    assert @mc.audit_log.in_list? "Product ID", @product_id1, @admin, change_reason: @change_reason_create1
    assert @mc.audit_log.in_list? "Quantity", @variant_qty1, @admin, change_reason: @change_reason_create1
    assert @mc.audit_log.in_list? "Baseline Master Template", @mt_db_id1, @admin, change_reason: @change_reason_create1
    assert @mc.audit_log.in_list? "Product Name", @variant_title2, @admin, change_reason: @change_reason_edit, old_value: @variant_title1
    assert @mc.audit_log.in_list? "Product ID", @product_id2, @admin, change_reason: @change_reason_edit, old_value: @product_id1
    assert @mc.audit_log.in_list? "Quantity", @variant_qty2, @admin, change_reason: @change_reason_edit, old_value: @variant_qty1
  end

  def test_creating_or_editing_variations_produces_audit_log_entries
    sql_query_title = "SELECT * FROM [mfg_cfg].[numeric_limits] WHERE variant_id = '#{@variant_id1}'"
    num_limit_id_results = @mc.do.run_query(sql_query_title)
    @num_limit_id = num_limit_id_results[0]

    @change_reason_create_na1 = "Created Not Applicable variation for phase step #{@order_label_na} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_create_param1 = "Created Parameter variation for phase step #{@order_label_param} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_create_rim1 = "Created Required Input Match variation for phase step #{@order_label_rim} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_create_num1 = "Created Numeric Limits variation (ID: #{@num_limit_id}) for phase step #{@order_label_num} in variant - #{@variant_title1} (#{@variant_id1})"
    
    @change_reason_edit_na1 = "Edited Not Applicable variation for phase step #{@order_label_na} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_edit_param1 = "Edited Parameter variation for phase step #{@order_label_param} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_edit_rim1 = "Edited Required Input Match variation for phase step #{@order_label_rim} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_edit_num1 = "Edited Numeric Limits variation (ID: #{@num_limit_id}) for phase step #{@order_label_num} in variant - #{@variant_title1} (#{@variant_id1})"

    @mc.do.search_audit_log @application, change_reason: @variant_id1, changes_by_user: @admin
    @mc.audit_log.multiple_changes_element.scroll_into_view
    sleep 1

    #check creation
    assert @mc.audit_log.in_list? "Title", @parameter_value1 , @admin, change_reason: @change_reason_create_param1
    assert @mc.audit_log.in_list? "N/A Configured", @variation_na1_aud, @admin, change_reason: @change_reason_create_na1
    assert @mc.audit_log.in_list? "Input Match Value", @variation_rim1, @admin, change_reason: @change_reason_create_rim1
    assert @mc.audit_log.in_list? "Minimum Value", @variation_num1_range[0].to_s, @admin, change_reason: @change_reason_create_num1
    assert @mc.audit_log.in_list? "Maximum Value", @variation_num1_range[1].to_s, @admin, change_reason: @change_reason_create_num1
    assert @mc.audit_log.in_list? "Displayed on Interface", @variation_na2_aud, @admin, change_reason: @change_reason_create_rim1


    #check edits
    assert @mc.audit_log.in_list? "Title", @parameter_value2 , @admin, change_reason: @change_reason_edit_param1
    assert @mc.audit_log.in_list? "N/A Configured", @variation_na2_aud, @admin, change_reason: @change_reason_edit_na1, old_value: @variation_na1_aud
    assert @mc.audit_log.in_list? "Minimum Value", @variation_num2_range[0].to_s, @admin, change_reason: @change_reason_edit_num1, old_value: @variation_num1_range[0].to_s
    assert @mc.audit_log.in_list? "Maximum Value", @variation_num2_range[1].to_s, @admin, change_reason: @change_reason_edit_num1, old_value: @variation_num1_range[1].to_s
    assert @mc.audit_log.in_list? "Displayed on Interface", @variation_na1_aud, @admin, change_reason: @change_reason_edit_rim1, old_value: @variation_na2_aud
  end

  def test_revising_master_templates_produces_audit_log_entries_for_copied_variants
    @mt_id_revised = @mt_id + "-REVISED"

    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by :product_id, @mt_id
    @mc.master_batch_record_list.revise_master_batch_record @mt_id
    @mc.master_batch_record_list.edit_master_batch_record @mt_id_revised
    wait_until {@mc.structure_builder.back_element.visible? }
    @mt_db_id2 = @mc.url.split('/').last

    @mc.go_to.ebr.variant_view_all
    @mc.variant_list.filter_for variant_name: @variant_title2, variant_id: @product_id2
    @mc.variant_list.revision_header
    @mc.variant_list.revision_header
    @mc.variant_list.actions_edit_variant @product_id2
    wait_until {@mc.variant_detail.back_element.visible? }
    @variant_id2 = @mc.url.split('/').last

    @mc.do.search_audit_log @application, change_reason: @variant_id2, changes_by_user: @admin
    @mc.audit_log.multiple_changes_element.scroll_into_view

    sql_query_title = "SELECT * FROM [mfg_cfg].[numeric_limits] WHERE variant_id = '#{@variant_id2}'"
    num_limit_id_results = @mc.do.run_query(sql_query_title)
    @num_limit_id = num_limit_id_results[0]

    @change_reason_create_na2 = "Created Not Applicable variation for phase step #{@order_label_na} in variant - #{@variant_title2} (#{@variant_id2})"
    @change_reason_create_param2 = "Created Parameter variation for phase step #{@order_label_param} in variant - #{@variant_title2} (#{@variant_id2})"
    @change_reason_create_rim2 = "Created Required Input Match variation for phase step #{@order_label_rim} in variant - #{@variant_title2} (#{@variant_id2})"
    @change_reason_create_num2 = "Created Numeric Limits variation (ID: #{@num_limit_id}) for phase step #{@order_label_num} in variant - #{@variant_title1} (#{@variant_id1})"
    @change_reason_create2 = "Created #{@product_id2} - #{@variant_title2} (#{@variant_id2})"

    assert @mc.audit_log.in_list? "Product Name", @variant_title2, @admin, change_reason: @change_reason_create2
    assert @mc.audit_log.in_list? "Product ID", @product_id2, @admin, change_reason: @change_reason_create2
    assert @mc.audit_log.in_list? "Quantity", @variant_qty2, @admin, change_reason: @change_reason_create2
    assert @mc.audit_log.in_list? "Baseline Master Template", @mt_db_id2, @admin, change_reason: @change_reason_create2
    assert @mc.audit_log.in_list? "N/A Configured", @variation_na2_aud, @admin, change_reason: @change_reason_create_na2
    assert @mc.audit_log.in_list? "Input Match Value", @variation_rim2, @admin, change_reason: @change_reason_create_rim2
    assert @mc.audit_log.in_list? "Minimum Value", @variation_num2_range[0].to_s, @admin, change_reason: @change_reason_create_num2
    assert @mc.audit_log.in_list? "Maximum Value", @variation_num2_range[1].to_s, @admin, change_reason: @change_reason_create_num2
    assert @mc.audit_log.in_list? "Displayed on Interface", @variation_na1_aud, @admin, change_reason: @change_reason_create_rim2
  end

  def clean_up
    [@variant_id1, @variant_id2].each{|id|
        sql_query_br = "DELETE FROM [mfg_exe].[batch_records] WHERE variant_id ='#{id}'"
        @mc.do.run_query(sql_query_br, print_query: true)
    
        sql_query_title = "DELETE FROM [mfg_cfg].[variation_phase_step_title] WHERE variant_id = '#{id}'"
        @mc.do.run_query(sql_query_title, print_query: true)
    
        sql_query_na = "DELETE FROM [mfg_cfg].[variation_phase_step_na] WHERE variant_id = '#{id}'"
        @mc.do.run_query(sql_query_na, print_query: true)
    
        sql_query_limit = "DELETE FROM [mfg_cfg].[numeric_limits] WHERE variant_id = '#{id}'"
        @mc.do.run_query(sql_query_limit, print_query: true)
    
        sql_query_limit = "DELETE FROM [mfg_cfg].[required_input_matches] WHERE variant_id = '#{id}'"
        @mc.do.run_query(sql_query_limit, print_query: true)
    }
    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@variant_title2_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end
end
