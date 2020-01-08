require "mastercontrol-test-suite"

class EbrFRS < MCFunctionalTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_id = uniq("prod_id")
    @product_name = uniq("name")
    @lot_1 = uniq("lot_1")

    pre_test

    test_add_phase_link
    test_view_linked_phases
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, phase_count: 2
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
    @mc.phase_step.add_general_text
  end

  def test_add_phase_link
    @mc.phase_step.click_on_linked_phases_option "1.1.2 - Phase 2"
    assert @mc.phase_step.linked_phase_element.visible?
  end

  def test_view_linked_phases
    @mc.phase_step.back
    @mc.structure_builder.phase_level.select_unit "2"
    @mc.structure_builder.phase_level.settings "2"
    @mc.structure_builder.phase_level.open_phase_builder "2"
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_1
    @mc.ebr_navigation.go_to_first "phase", @lot_1
    assert @mc.phase.phase_steps[0].linked_phase_element.visible?
    @mc.phase.phase_steps[0].linked_phase_element.click
    @mc.use_window 2
    assert @mc.phase.phase_steps[0].phase_header_element.text.include? "Phase 2"
  end
end
