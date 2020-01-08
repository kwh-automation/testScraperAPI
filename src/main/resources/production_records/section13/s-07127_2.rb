require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq("7127")
    @product_id = uniq("prod_id")
    @product_name = uniq("name")
    @production_user = uniq("Prod_user")
    @sign_off_user = uniq("sign_off_user")
    @esig = env["admin_esig"]
    @connection = MCAPI.new

    pre_test
    test_production_record_cannot_be_released_without_operation_sign_off
    test_user_can_sign_off_on_operation_after_phase_completion
    test_production_record_cannot_be_released_without_unit_procedure_sign_off
    test_user_can_sign_off_on_unit_procedure_after_operation_completion
  end

  def pre_test
    @mc.do.login @admin, @admin_pass
    MCAPIs.create_user @production_user, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @sign_off_user, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@admin, @production_user, @sign_off_user], connection: @connection

    @mc.ebr.open_new_mbr_structure @product_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit_with_sign_offs set_name: "Unit procedure 1", has_first_sign_off: true, has_second_sign_off: false
    @mc.structure_builder.operation_level.add_unit_with_sign_offs set_name: "Operation 1", has_first_sign_off: true, has_second_sign_off: true
    @mc.structure_builder.phase_level.add_unit set_name: "Phase 1"
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_lot @lot_number
  end

  def test_production_record_cannot_be_released_without_operation_sign_off
    @mc.ebr_navigation.sidenav_navigate_to "1.1.1"
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.completion.complete
    @mc.go_to.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    assert !(@mc.batch_record_list.get_status_data 0).include?("Ready")
  end

  def test_user_can_sign_off_on_operation_after_phase_completion
    @mc.ebr_navigation.go_to_lot @lot_number
    @mc.ebr_navigation.sidenav_navigate_to "1.1"
    @mc.accountability.perform_first_sign_off @sign_off_user, @esig
    @mc.accountability.perform_second_sign_off @production_user, @esig
  end

  def test_production_record_cannot_be_released_without_unit_procedure_sign_off
    @mc.go_to.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    assert !(@mc.batch_record_list.get_status_data 0).include?("Ready")
  end

  def test_user_can_sign_off_on_unit_procedure_after_operation_completion
    @mc.ebr_navigation.go_to_lot @lot_number
    @mc.ebr_navigation.sidenav_navigate_to "1"
    @mc.accountability.perform_first_sign_off @sign_off_user, @esig
  end
end