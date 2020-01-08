require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @MBR_name = uniq('MBR_name')
    @MBR_id = uniq('MBR_id')
    @lot_number = uniq('lot_')

    pre_test
    test_tables_that_were_configured_are_displayed_on_accountability_page
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @MBR_name, @MBR_id, open_phase_builder: true
    create_mbr
    @mc.do.publish_master_batch_record @MBR_name, @MBR_id
    @mc.do.create_batch_record "#{@MBR_id} #{@MBR_name}", @lot_number
    @mc.ebr_navigation.go_to_first('Unit procedure', @lot_number)
  end

  def test_tables_that_were_configured_are_displayed_on_accountability_page
    @mc.ebr_navigation.go_to_accountability

    assert @mc.accountability.people_table_element.visible?

    @mc.accountability.open_table_link 'people'
    cycle_windows "Phase 1"

    assert @mc.accountability.materials_table_element.visible?

    @mc.accountability.open_table_link 'materials'
    cycle_windows "Phase 2"

    assert @mc.accountability.equipment_table_element.visible?

    @mc.accountability.open_table_link 'equipment'
    cycle_windows "Phase 3"
  end

  private

  def create_mbr
    @mc.phase_step.add_general_text
    @mc.phase_builder.phase_iterator
    @mc.phase_builder.row_type_selector
    @mc.phase_builder.lot_dependent_dropdown_item
    @mc.phase_builder.iterations = '1'
    @mc.phase_builder.table_section_dropdown
    @mc.phase_builder.people_section
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
    @mc.phase_step.general_text.back
  end

  def cycle_windows phase
    @mc.use_window 2
    wait_until{@mc.batch_phase_step.header_text_element.visible?}
    assert (@mc.batch_phase_step.header_text_element.text.include? phase)
    @mc.close_window
    @mc.use_window 1
  end
end
