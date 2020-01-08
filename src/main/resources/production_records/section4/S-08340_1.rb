require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-08340_1_', false)
    @product_id = uniq('1', false)
    @required_text_2 = uniq('required 2', false)

    pre_test
    test_required_input_match_can_be_applied_to_general_text
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, procedure_count: 1, operation_count: 1, phase_count: 1, open_phase_builder: true, open_phase: '1'
    assert @mc.phase_step.phase_complete_element.visible?
  end

  def test_required_input_match_can_be_applied_to_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block '1', text: 'hello this is a test 1'
    @mc.phase_step.general_text.click_on_step_label 1
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.disable_displayed_on_interface
    @mc.phase_step.general_text.cancel
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = 'required'
    @mc.phase_step.general_text.save
    @mc.phase_step.general_text.edit_required_input
    @mc.phase_step.general_text.required_input_text = 'edited!'
    @mc.phase_step.general_text.save
    @mc.phase_step.back
    @mc.structure_builder.phase_level.select_unit 1
    @mc.structure_builder.phase_level.settings 1
    @mc.structure_builder.phase_level.open_phase_builder 1
    @mc.phase_step.general_text.click_on_step_label 1

    assert @mc.phase_step.general_text.is_required_input_match_tag_added?(1)

    @mc.phase_step.general_text.delete_required_input_match

    assert !@mc.phase_step.general_text.required_input_match

    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = 'required'
    @mc.phase_step.general_text.disable_displayed_on_interface
    @mc.phase_step.general_text.save
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block '2', text: 'hello this is a test 2'
    @mc.phase_step.general_text.click_on_step_label 2
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = @required_text_2
    @mc.phase_step.general_text.save
    @mc.phase_step.back
    @mc.structure_builder.back
    @mc.do.move_downloaded_files '', 'pdf'
    @mc.master_batch_record_list.view_pdf @product_id
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name

    assert @mc.pdf.find_text("Value to be matched: #{@required_text_2}")

    @mc.pdf.close
    @mc.master_batch_record_list.edit_master_batch_record @product_id
  end
end
