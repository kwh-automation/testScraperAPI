# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('product_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')

    pre_test
    test_that_the_production_navigation_tab_has_quick_view_tab_and_a_view_all_tab
    test_quick_view_tab_shows_assigned_phases
    test_quick_view_tab_shows_phases_with_phase_steps_with_authorized_roles
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
    make_mbr_with_quick_view_roles
    @mc.ebr_navigation.go_to_lot @lot
  end

  def test_that_the_production_navigation_tab_has_quick_view_tab_and_a_view_all_tab
    @mc.ebr_navigation.select_side_nav_tab 1
    sleep 1
    assert @mc.ebr_navigation.tab_selected? 1
    @mc.ebr_navigation.select_side_nav_tab 0
    sleep 1
    assert @mc.ebr_navigation.tab_selected? 0
  end

  def test_quick_view_tab_shows_assigned_phases
    assert @mc.ebr_navigation.phase_shown?(1), 'Phase 1 is not shown'
    assert !@mc.ebr_navigation.phase_shown?(2), 'Phase 2 is shown'
  end

  def test_quick_view_tab_shows_phases_with_phase_steps_with_authorized_roles
    assert @mc.ebr_navigation.phase_shown?(3), 'Phase 3 is not shown'
  end

  private

  def make_mbr_with_quick_view_roles
    @mc.ebr.open_new_mbr_structure @product_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    sleep 1
    @mc.structure_builder.edit_mbr.header_settings.save
    sleep 2
    @mc.structure_builder.procedure_level.add_unit set_name: 'Unit procedure 1'
    @mc.structure_builder.operation_level.add_unit set_name: 'Operation 1'
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 1'
    sleep 1
    @mc.structure_builder.phase_level.select_unit '1'
    @mc.structure_builder.phase_level.settings '1'
    @mc.structure_builder.phase_level.enable_assign_roles
    @mc.structure_builder.phase_level.assign_view_roles = env['test_admin_role']
    @mc.structure_builder.phase_level.save
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 2'
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 3'
    sleep 1
    @mc.structure_builder.phase_level.select_unit "3"
    @mc.structure_builder.phase_level.settings "3"
    @mc.structure_builder.phase_level.open_phase_builder "3"
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_authorized_roles
    @mc.phase_step.general_text.authorized_roles_toolbar
    @mc.phase_step.general_text.choose_authorized_role env['test_admin_role']
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot
  end
end
