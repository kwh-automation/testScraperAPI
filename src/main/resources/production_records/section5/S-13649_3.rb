require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @title = uniq('Title_')
    @title_no_uniq = uniq('Title_', false)
    @id = uniq('VariantId_', false)
    @template_id = uniq('MT_id_')
    @template_name = uniq('MT_name_')
    @template = "#{@template_id} #{@template_name}"
    @lot_number = uniq('Lot_')
    @phase = '1.1.1'
    @varying_properties = ['parameter']
    @new_parameter1 = 'This is a new phase step title'
    @new_parameter2 = 'Another parameter variation'
    @connection = MCAPI.new

    pre_test
    test_production_record_contains_all_variations
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @template_name, @template_id, default_lot_amount: '2', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step 1'
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 2, text: 'General Text Step 2'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    MCAPIs.approve_MBR @template_name, connection: @connection

    @mc.go_to.ebr
    @mc.do.create_variant @title, @id, parent_template: @template
    @mc.variant_detail.create_variation @phase, '1', @varying_properties, new_parameter: @new_parameter1
    @mc.variant_detail.create_variation @phase, '2', @varying_properties, new_parameter: @new_parameter2
    @variant_id = @mc.url.split('/').last
    @mc.variant_detail.back
  end

  def test_production_record_contains_all_variations
    @mc.do.create_batch_record "#{@id} #{@title}", @lot_number
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_number
    @mc.ebr_navigation.sidenav_navigate_to @phase
    assert (@mc.phase.phase_steps[0].phase_step_title.include? @new_parameter1), 'The production record does not contain the phase step title variation for 1.1.1.1'
    assert (@mc.phase.phase_steps[1].phase_step_title.include? @new_parameter2), 'The production record does not contain the phase step title variation for 1.1.1.2'
  end

  def clean_up
    sql_query_br = "DELETE FROM [mfg_exe].[batch_records] WHERE variant_id ='#{@variant_id}'"
    @mc.do.run_query(sql_query_br, print_query: true)

    sql_query_title = "DELETE FROM [mfg_cfg].[variation_phase_step_title] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_title, print_query: true)

    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@title_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end

end