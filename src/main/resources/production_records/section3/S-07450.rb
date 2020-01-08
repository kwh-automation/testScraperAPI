require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_id = uniq("prod_id")
    @duplicate_id = "#{@product_id}-DUPLICATE"
    @product_name = uniq("name")
    @unit_procedure = uniq("up_")
    @operation_1 = uniq("op_1_")
    @operation_2 = uniq("op_2_")
    @phase_1 = uniq("phase_1_")
    @phase_2 = uniq("phase_2_")

    pre_test
    test_duplicating_master_template
    test_that_duplicate_maintains_structure
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @product_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: @unit_procedure
    @mc.structure_builder.operation_level.add_unit set_name:@operation_1
    @mc.structure_builder.operation_level.add_unit set_name:@operation_2
    @mc.structure_builder.operation_level.select_unit(1)
    @mc.structure_builder.phase_level.add_unit set_name:@phase_1
    @mc.structure_builder.operation_level.select_unit(2)
    @mc.structure_builder.phase_level.add_unit set_name:@phase_2
    @mc.structure_builder.back
  end

  def test_duplicating_master_template
    @mc.go_to.ebr
    @mc.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by :product_id, @product_id
    @mc.master_batch_record_list.duplicate_mbr @product_id
    assert @mc.master_batch_record_list.in_list?(@duplicate_id)
  end

  def test_that_duplicate_maintains_structure
    @mc.master_batch_record_list.edit_master_batch_record @duplicate_id
    wait_until { @mc.structure_builder.procedure_level.does_unit_exist?(1) }
    assert @mc.structure_builder.procedure_level.does_unit_exist?(1)
    @mc.structure_builder.procedure_level.select_unit(1)
    assert @mc.structure_builder.operation_level.does_unit_exist?(1)
    assert @mc.structure_builder.operation_level.does_unit_exist?(2)
    @mc.structure_builder.operation_level.select_unit(1)
    assert @mc.structure_builder.phase_level.does_unit_exist?(1)
    @mc.structure_builder.operation_level.select_unit(2)
    assert @mc.structure_builder.phase_level.does_unit_exist?(1)
  end
end