require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name_1 = uniq("where_used_1")
    @product_id_1 = uniq("where_used_product_id_1", false)
    @lot_number_1 = uniq("lot_1", true)
    @unit_procedure_1 = uniq("UP_")
    @operation_1 = uniq("OP_")
    @phase_1 = uniq("PHASE_")

    @mbr_name_2 = uniq("where_used_2")
    @product_id_2 = uniq("where_used_product_id_2", false)
    @lot_number_2 = uniq("lot_2", true)

    @mbr_name_3 = uniq("where_used_3")
    @product_id_3 = uniq("where_used_product_id_3", false)
    @lot_number_3 = uniq("lot_3", true)

    pre_test
    test_where_used_can_be_searched_via_master_template_name_and_product_id
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    create_mbr @mbr_name_1, @product_id_1
    create_structure_level_and_save_template @unit_procedure_1
    create_structure_level_and_save_template @operation_1
    create_structure_level_and_save_template @phase_1
    create_mbr @mbr_name_2, @product_id_2
    import_template @unit_procedure_1
    import_template @operation_1
    import_template @phase_1
    create_mbr @mbr_name_3, @product_id_3
    import_template @unit_procedure_1
    import_template @operation_1
    import_template @phase_1
  end

  def test_where_used_can_be_searched_via_master_template_name_and_product_id
    open_template_library
    confirm_structure_level_template_found_in_where_used @unit_procedure_1
    @mc.where_used_modal._close_where_used
    @mc.template_library._operation_level_templates
    confirm_structure_level_template_found_in_where_used @operation_1
    @mc.where_used_modal._close_where_used
    @mc.template_library._phase_level_templates
    confirm_structure_level_template_found_in_where_used @phase_1
    @mc.where_used_modal._close_where_used
  end

  private

  def create_mbr mbr_name, product_id
    @mc.ebr.open_new_mbr_structure mbr_name, product_id
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
  end

  def create_structure_level_and_save_template level_name
    if level_name.include? "UP_"
      @mc.structure_builder.procedure_level.add_unit set_name: level_name
      @mc.structure_builder.procedure_level.save_template
      @mc.template_name.submit
      @mc.structure_builder.procedure_level.select_unit 1
    elsif level_name.include? "OP_"
      @mc.structure_builder.operation_level.add_unit set_name: level_name
      @mc.structure_builder.operation_level.save_template
      @mc.template_name.submit
      @mc.structure_builder.operation_level.select_unit 1
    else
      @mc.structure_builder.phase_level.add_unit set_name: level_name
      @mc.structure_builder.phase_level.save_template
      @mc.template_name.submit
      @mc.structure_builder.phase_level.select_unit 1
    end
  end

  def import_template template_name
    if template_name.include? "UP_"
      @mc.template_library.procedure_library.import_template template_name
    elsif template_name.include? "OP_"
      @mc.template_library.operation_library.import_template template_name
    else
      @mc.template_library.phase_library.import_template template_name
    end
  end

  def compare_after_search mbr_name
    assert @mc.where_used_modal.where_used_master_template_exists? mbr_name
  end

  def find_and_verify_master_template_in_where_used search, compare
    @mc.where_used_modal.search search
    @mc.wait_for_video
    compare_after_search compare
    @mc.where_used_modal.clear_search
  end

  def open_template_library
    @mc.structure_builder.options
    @mc.structure_builder.open_template_library
  end

  def confirm_structure_level_template_found_in_where_used structure_level_id
    @mc.template_library.expanded_tab_search structure_level_id
    @mc.template_library.select_single_template
    @mc.wait_for_video
    @mc.where_used_modal.select_where_used
    find_and_verify_master_template_in_where_used @mbr_name_3, @mbr_name_3
    find_and_verify_master_template_in_where_used @product_id_3, @mbr_name_3
  end

end