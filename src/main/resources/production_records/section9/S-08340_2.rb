# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-08340_2_', false)
    @product_id = uniq('1', false)
    @lot_number = uniq('imalot_')
    @required_text_two = uniq('required 2', false)

    pre_test
    test_required_input_must_match_predefined_input
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    create_master_template

    @mc.do.move_downloaded_files '', 'pdf'
    @mc.master_batch_record_list.view_pdf @product_id
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
    @mc.pdf.close
    @mc.master_batch_record_list.edit_master_batch_record @product_id
  end

  def test_required_input_must_match_predefined_input
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number

    @mc.batch_record_list.select_batch_record_in_list @lot_number
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
    @mc.phase.phase_steps[0].set_text 'not required'
    @mc.phase.phase_steps[0].blur wait_for_completion: false

    assert @mc.phase.phase_steps[0].out_of_specification?, 'Out of Specification message should have been displayed'

    @mc.phase.phase_steps[0].set_text 'required'
    @mc.phase.phase_steps[0].blur

    assert @mc.phase.phase_steps[0].captured_value == 'required', 'Required Input value should have been captured'
    assert @mc.phase.phase_steps[1].required_input_matches_message? "Value to be matched: #{@required_text_two}"

    @mc.phase.phase_steps[1].set_text 'required'
    @mc.phase.phase_steps[1].blur wait_for_completion: false

    assert @mc.phase.phase_steps[1].out_of_specification?, 'Out of Specification message should have been displayed'

    @mc.phase.phase_steps[1].set_text @required_text_two
    @mc.phase.phase_steps[1].blur
    @mc.go_to.ebr.batch_record_view_all
    @mc.do.move_downloaded_files '', 'pdf'
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name

    assert @mc.pdf.find_text("Value to be matched: #{@required_text_two}")

    @mc.pdf.close
  end

  def clean_up
    @mc.pdf.close
  end

  private

  def create_master_template
    @mc.do.create_master_batch_record @product_name,
                                      @product_id,
                                      procedure_count: 1,
                                      operation_count: 1,
                                      phase_count: 1,
                                      open_phase_builder: true,
                                      open_phase: '1'
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
    @mc.phase_step.general_text.delete_required_input_match
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = 'required'
    @mc.phase_step.general_text.disable_displayed_on_interface
    @mc.phase_step.general_text.save
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block '2', text: 'hello this is a test 2'
    @mc.phase_step.general_text.click_on_step_label 2
    @mc.phase_step.general_text.enable_required_input_match
    @mc.phase_step.general_text.required_input_text = @required_text_two
    @mc.phase_step.general_text.save
    @mc.phase_step.back
    @mc.structure_builder.back
  end
end
