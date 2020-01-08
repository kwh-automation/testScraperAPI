require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("add_inspections_tile")
    @product_id = uniq("add_inspections_tile", false)
    @lot_number = uniq("lot_", true)

    pre_test
    test_aql_inspections_property_exists_on_data_type
    test_user_can_view_master_templates_with_inspections_through_inspections_tile
    test_user_can_view_all_pass_fail_inspections_within_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @mbr_name, @product_id, open_phase_builder: true
  end

  def test_aql_inspections_property_exists_on_data_type
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_add_to_inspections
    assert @mc.phase_step.pass_fail_step._add_to_inspections
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    @mc.go_to.ebr
  end

  def test_user_can_view_master_templates_with_inspections_through_inspections_tile
    assert @mc.ebr.inspections_element.exists?
    @mc.go_to.ebr.inspections
    wait_until { @mc.inspections.inspections_title_element.visible? }
    assert @mc.inspections.inspections_title_element.attribute('innerText').include? "AQL Inspection Plans"
    @mc.inspections.filter_by :master_template, @mbr_name
    assert @mc.inspections.master_template_name @mbr_name
    assert @mc.inspections.product_id @product_id
  end

  def test_user_can_view_all_pass_fail_inspections_within_master_template
    @mc.inspections.open_master_template @mbr_name
    wait_until { @mc.manage_inspections.manage_inspections_title_element.visible? }
    assert @mc.manage_inspections.manage_inspections_title_element.attribute('innerText').include? "Manage AQL Inspection"
  end

end