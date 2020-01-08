require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("manage_inspections")
    @product_id = uniq("manage_inspections", false)
    @lot_number_1 = uniq("lot_1", true)
    @lot_number_2 = uniq("lot_2", true)

    pre_test
    test_user_can_enter_add_and_remove_quantity_ranges
    test_user_can_assign_severity_levels
    test_user_can_enter_reject_count
    test_changes_to_inspections_plan_apply_to_all_production_records_sharing_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @mbr_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_add_to_inspections
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.enable_add_to_inspections
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.go_to.ebr
    @mc.go_to.ebr.inspections
    @mc.inspections.filter_by :master_template, @mbr_name
    @mc.inspections.open_master_template @mbr_name
  end

  def test_user_can_enter_add_and_remove_quantity_ranges
    @mc.manage_inspections.add_range
    @mc.manage_inspections.add_range
    @mc.manage_inspections.remove_range 3
    @mc.manage_inspections.set_range 10, 500
    @mc.manage_inspections.set_range 600, 900, range: 2
    @mc.manage_inspections.select_existing_range 1
    assert @mc.manage_inspections.ranges_list_element.attribute('innerText').include? "10"
    assert @mc.manage_inspections.ranges_list_element.attribute('innerText').include? "500"
  end

  def test_user_can_assign_severity_levels
    wait_until { @mc.manage_inspections.severity_element.visible? }
    @mc.manage_inspections.severity_level "Minor", row: 1
    @mc.manage_inspections.severity_level "Major", row: 1
    @mc.manage_inspections.severity_level "Critical", row: 1
    @mc.manage_inspections.severity_level "Zero Tolerance", row: 1
    @mc.manage_inspections.severity_level "Minor", row: 2
  end

  def test_user_can_enter_reject_count
    assert @mc.manage_inspections.reject_count_element.visible?
    @mc.manage_inspections.add_reject_count 10, row: 1
    @mc.manage_inspections.select_existing_range 2

    @mc.manage_inspections.add_reject_count 20, row: 2
    @mc.manage_inspections.select_existing_range 1

    assert @mc.manage_inspections.check_reject_count step_id: '1.1.1.1', check_value: 10
    assert @mc.manage_inspections.check_accept_count step_id: '1.1.1.1', check_value: 9
  end

  def test_changes_to_inspections_plan_apply_to_all_production_records_sharing_master_template
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number_1, lot_amount: 20
    @mc.batch_record_list.filter_by :lot_number, @lot_number_1
    @mc.batch_record_list.view_irp @lot_number_1
    @mc.inspection_review.open_severity_tab :zero_tolerance
    zero_accept_reject_1 = @mc.inspection_review.get_accept_reject_count "ZERO_TOLERANCE", row: 1
    assert zero_accept_reject_1 == ["9", "10"]

    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number_2, lot_amount: 600
    @mc.batch_record_list.filter_by :lot_number, @lot_number_2
    @mc.batch_record_list.view_irp @lot_number_2
    @mc.inspection_review.open_severity_tab :minor
    zero_accept_reject_2 = @mc.inspection_review.get_accept_reject_count "MINOR", row: 1
    assert zero_accept_reject_2 == ["19", "20"]

    @mc.go_to.ebr
    @mc.go_to.ebr.inspections
    @mc.inspections.filter_by :master_template, @mbr_name
    @mc.inspections.open_master_template @mbr_name
    wait_until { @mc.manage_inspections.manage_inspections_title_element.visible? }
    @mc.manage_inspections.select_existing_range 1
    @mc.manage_inspections.add_reject_count 100, row: 1
    @mc.manage_inspections.select_existing_range 2
    @mc.manage_inspections.add_reject_count 200, row: 2

    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number_1
    @mc.batch_record_list.view_irp @lot_number_1
    @mc.inspection_review.open_severity_tab :zero_tolerance
    zero_accept_reject_3 = @mc.inspection_review.get_accept_reject_count "ZERO_TOLERANCE", row: 1
    assert zero_accept_reject_3 == ["99", "100"]

    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number_2
    @mc.batch_record_list.view_irp @lot_number_2
    @mc.inspection_review.open_severity_tab :minor
    zero_accept_reject_4 = @mc.inspection_review.get_accept_reject_count "MINOR", row: 1
    assert zero_accept_reject_4 == ["199", "200"]
  end

end
