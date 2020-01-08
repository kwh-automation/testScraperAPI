require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @MBR_name = uniq('MBR_name')
    @MBR_id = uniq('MBR_id')

    pre_test
    test_table_can_be_configured_to_display_in_accountability_page
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @MBR_name, @MBR_id, open_phase_builder: true
  end

  def test_table_can_be_configured_to_display_in_accountability_page
    @mc.phase_step.add_general_text
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    @mc.phase_builder.iterations = '1'
    @mc.phase_builder.table_section_dropdown
    @mc.phase_builder.people_section

    assert @mc.phase_builder.current_selection_element.attribute('innerText') == 'People Section'

    @mc.phase_step.general_text.back
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 2'
    @mc.structure_builder.phase_level.configure_phase 2
    @mc.phase_step.add_general_text
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    @mc.phase_builder.iterations = '1'
    @mc.phase_builder.table_section_dropdown
    @mc.phase_builder.materials_section

    assert @mc.phase_builder.current_selection_element.attribute('innerText') == 'Materials Section'

    @mc.phase_step.general_text.back
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 3'
    @mc.structure_builder.phase_level.configure_phase 3
    @mc.phase_step.add_general_text
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    @mc.phase_builder.iterations = '1'
    @mc.phase_builder.table_section_dropdown
    @mc.phase_builder.equipment_section

    assert @mc.phase_builder.current_selection_element.attribute('innerText') == 'Equipment Section'
  end
end
