require "mastercontrol-test-suite"

class Variants < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_id1 = uniq('variant_id1_')
    @variant_title1 = uniq('variant_title1_')
    @title_no_uniq1 = uniq('variant_title1_', false)
    @product_id2 = uniq('variant_id2_')
    @variant_title2 = uniq('variant_title2_')
    @lot_number = uniq('variant_lot_')
    @mt_name = uniq('mt_name_')
    @mt_id = uniq('mt_id_')
    @template = "#{@mt_id} #{@mt_name}"
    @connection = MCAPI.new
    
    pre_test
    test_user_can_create_variant
    test_user_can_edit_variant
    test_in_process_production_record_updates
    test_variants_are_copied_when_revising_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @mt_name, @mt_id, default_lot_amount: '5', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    MCAPIs.approve_MBR @mt_name, connection: @connection
  end

  def test_user_can_create_variant
    @mc.do.create_variant @variant_title1, @product_id1, parent_template: @template
    assert @mc.variant_detail.variant_heading_element.text == "#{@product_id1} - #{@variant_title1}", 'The variant header does not have the correct product id and variant title.'
  end

  def test_user_can_edit_variant
    @mc.variant_detail.edit_variant
    @mc.variant_modal.product_name = @variant_title2
    @mc.variant_modal.product_id = @product_id2
    @mc.variant_modal.save
    @variant_id = @mc.url.split('/').last
    assert @mc.variant_detail.variant_heading_element.text == "#{@product_id2} - #{@variant_title2}", 'The variant header does not have the correct product id and variant title after edit.'
  end

  def test_in_process_production_record_updates
    @mc.do.create_batch_record "#{@product_id2} #{@variant_title2}", @lot_number
    @mc.ebr_navigation.go_to_first('unit procedure', @lot_number)
    assert (@mc.accountability.mbr_name_element.text.include? @variant_title2), 'The production record does not display the correct variant title.'
    assert (@mc.accountability.product_id_element.text.include? @product_id2), 'The production record does not display the correct product id.'

    @mc.go_to.ebr.variant_view_all
    @mc.variant_list.filter_for variant_name: @variant_title2, variant_id: @product_id2
    @mc.variant_list.actions_edit_variant @product_id2
    @mc.variant_detail.edit_variant
    @mc.variant_modal.product_name = @variant_title1
    @mc.variant_modal.product_id = @product_id1
    @mc.variant_modal.save
    @mc.variant_detail.in_process_warning_modal_continue

    @mc.ebr_navigation.go_to_first('unit procedure', @lot_number)
    assert (@mc.accountability.mbr_name_element.text.include? @variant_title1), 'The production record does not display the correct variant title after varying.'
    assert (@mc.accountability.product_id_element.text.include? @product_id1), 'The production record does not display the correct product id after varying.'
  end

  def test_variants_are_copied_when_revising_master_template
    @mt_id_revised = @mt_id + "-REVISED"
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by :product_id, @mt_id
    @mc.master_batch_record_list.revise_master_batch_record @mt_id
    @mc.master_batch_record_list.edit_master_batch_record @mt_id_revised
    wait_until {@mc.structure_builder.back_element.visible? }
    @mt_db_id2 = @mc.url.split('/').last
    @mc.go_to.ebr.variant_view_all
    @mc.variant_list.filter_for variant_name: @variant_title1, variant_id: @product_id1, base_template_revision: 'B'
    assert @mc.variant_list.actions_dropdown_exists? @product_id1
  end

  def clean_up
    sql_query_br = "DELETE FROM [mfg_exe].[batch_records] WHERE variant_id ='#{@variant_id}'"
    @mc.do.run_query(sql_query_br, print_query: true)

    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@title_no_uniq1}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end
end