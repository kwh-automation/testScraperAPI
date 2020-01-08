require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq("view_")
    @product_id = uniq("restriction_")
    @authorized = uniq("authorized_")
    @restricted = uniq("restricted_")
    @lot = uniq("restrict_view_")

    pre_test
    test_quick_view_roles_can_be_assigned_on_phases
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee:true
    @mc.go_to.ebr
    @mc.ebr.open_new_mbr_structure @product_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    sleep 1
    @mc.structure_builder.edit_mbr.header_settings.save
    sleep 2
    @mc.structure_builder.procedure_level.add_unit set_name:"Unit procedure 1"
    @mc.structure_builder.operation_level.add_unit set_name:"Operation 1"
    @mc.structure_builder.phase_level.add_unit set_name:"Phase 1"
    sleep 1
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
  end

  def test_quick_view_roles_can_be_assigned_on_phases
    @mc.structure_builder.phase_level.enable_assign_roles
    @mc.structure_builder.phase_level.assign_view_roles = "FT_ADMIN"
    @mc.wait_for_video
    assert ( @mc.structure_builder.phase_level.assigned_view_roles.include? "FT_ADMIN" )
    @mc.structure_builder.phase_level.save
    assert ( !@mc.error.displayed? )
  end

end
