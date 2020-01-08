# frozen_string_literal: true

require 'mastercontrol-test-suite'

class TestLinks < MCValidationTest
  include Ebr

  def test_this
    @doc_number = uniq('doc_', false)
    @infocard_text = uniq('infocard', false)
    @prod_id = uniq('1', false)
    @prod_name = uniq('s09881_', false)
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('Lot', false)
    @small_text_content = 'tiny'
    @large_text_content = '_Jim Hawkins, John Silver, Captain Amelia, Scroop, Mr. Arrow, Sarah Hawkins, Dr. Delbert'\
                          ' Doppler, Mr. Hawkins, B.E.N., Morph, Longbourne, Captain Nathaniel Flint, Billy Bones,'\
                          ' Fayvoon, Zoff, Blinko, Hands, Turnbuckle, Crex, Onus, Mertock, Hedley, Grewnge, Verne,'\
                          ' Krailoni, Torrance, Orcus Galacticus'
    @latest_as_of_date = 'latestAsOfDate'
    @static_true = 'static%3Dtrue'
    @static_false = 'static%3Dfalse'
    @instruction_link_one = 'instruction-link-1'

    pre_test
    test_instruction_document_link_points_to_most_recent_revision_before_data_capture
    test_hyperlink_points_to_most_recent_revision_before_data_capture
    test_instruction_document_link_points_to_document_that_was_current_at_time_of_first_data_capture
    test_hyperlink_points_to_document_that_was_current_at_time_of_first_data_capture
    test_phases_without_data_capture_still_have_dynamic_links
    test_revision_shows_in_execution
    test_check_pdf_for_static_links
    test_check_pdf_for_dynamic_links
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc_number, file_name: resource('small_text')
    @mc.infocard.quick_approve env['password'], env['admin_esig']
    @mc.do.create_master_batch_record @prod_name, @prod_id, phase_count: 2, open_phase_builder: true
    wait_until { @mc.phase_step._add_instruction_element.visible? }
    @mc.phase_step.add_general_text
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step_hyperlink.add_document_to_hyperlink @doc_number
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @infocard_text
    @infocard_link = (@mc.phase_step.instructions.add_infocard_link @infocard_text, @doc_number)
    @infocard_id = @infocard_link.match(/(ID%.+?%)|(ID%.+?.*)/)[0]
    assert @mc.phase_step.link_in_textfield_contains_value @infocard_id
    @mc.phase_step.back
    @mc.structure_builder.phase_level.select_unit 2
    @mc.structure_builder.phase_level.settings 2
    @mc.structure_builder.phase_level.open_phase_builder 2
    @mc.phase_step.add_general_text
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step_hyperlink.add_document_to_hyperlink @doc_number
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @infocard_text
    @infocard_link = (@mc.phase_step.instructions.add_infocard_link @infocard_text, @doc_number)
    @infocard_id = @infocard_link.match(/(ID%)(.+?)(%)/)[2]
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @prod_name, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_name}", @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
  end

  def test_instruction_document_link_points_to_most_recent_revision_before_data_capture
    @mc.phase.instructions.instruction_link @instruction_link_one
    use_other_tab
    wait_until { @mc.ready? }
    assert @mc.url.include? @infocard_id
    assert @mc.inline_document_viewer.text_contains? @small_text_content
    close_current_tab_and_return_to_first_tab
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    @mc.phase.instructions.instruction_link @instruction_link_one
    use_other_tab
    assert_static_link
    close_current_tab_and_return_to_first_tab
  end

  def test_hyperlink_points_to_most_recent_revision_before_data_capture
    @mc.phase.phase_steps[1].view_link
    use_other_tab
    wait_until { @mc.ready? }
    assert @mc.url.include? @infocard_id
    assert @mc.inline_document_viewer.text_contains? @small_text_content
    close_current_tab_and_return_to_first_tab
    wait_until { @mc.ready? }
    @mc.phase.phase_steps[1].complete
    wait_until { @mc.phase.phase_steps[1].date != '' }
    @mc.refresh # link isn't updating until you refresh the page, this was logged as defect D-08038
    @mc.phase.phase_steps[1].view_link
    use_other_tab
    assert_static_link
    close_current_tab_and_return_to_first_tab
  end

  def test_instruction_document_link_points_to_document_that_was_current_at_time_of_first_data_capture
    @mc.go_to.documents.view_documents
    @mc.documents_list.search.for_infocard @doc_number, 1
    @mc.documents_list.view_infocard @doc_number, 1
    @mc.do.revision_infocard @doc_number, 1, quick_approve: true, new_main_file: '299_chars_text'
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.instructions.instruction_link @instruction_link_one
    use_other_tab
    wait_until { @mc.ready? }
    assert @mc.url.include? @infocard_id
    assert_static_link
    assert @mc.inline_document_viewer.text_contains? @small_text_content
    close_current_tab_and_return_to_first_tab
  end

  def test_hyperlink_points_to_document_that_was_current_at_time_of_first_data_capture
    @mc.phase.phase_steps[1].view_link
    use_other_tab
    wait_until { @mc.ready? }
    assert_static_link
    assert @mc.inline_document_viewer.text_contains? @small_text_content
    close_current_tab_and_return_to_first_tab
  end

  def test_phases_without_data_capture_still_have_dynamic_links
    @mc.ebr_navigation.sidenav_navigate_to '1.1.2'
    wait_until { @mc.ebr_navigation.phase_header_element.attribute('innerText').include? 'Phase 2' }
    @mc.phase.instructions.instruction_link @instruction_link_one
    use_other_tab
    wait_until { @mc.ready? }
    assert_dynamic_link
    assert @mc.inline_document_viewer.text_contains? @large_text_content
    close_current_tab_and_return_to_first_tab
    @mc.phase.phase_steps[1].view_link
    use_other_tab
    wait_until { @mc.ready? }
    assert_dynamic_link
    assert @mc.inline_document_viewer.text_contains? @large_text_content
    close_current_tab_and_return_to_first_tab
  end

  def test_revision_shows_in_execution
    execution_assertions '1.1.1', 1
    execution_assertions '1.1.2', 2
  end

  def test_check_pdf_for_static_links
    generate_pdf
    pdf_assertions_doc 1, 1
    pdf_assertions_infocard 1, 1
  end

  def test_check_pdf_for_dynamic_links
    pdf_assertions_doc 2, 1
    pdf_assertions_infocard 2, 1
  end

  def clean_up
    @mc.pdf.close
  end

  private

  def assert_static_link
    assert @mc.url.include?(@latest_as_of_date) || !@mc.url.include?(@static_false)
  end

  def assert_dynamic_link
    assert @mc.url.include?(@static_false) && !@mc.url.include?(@latest_as_of_date)
  end

  def generate_pdf
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.do.move_downloaded_files '', 'pdf'
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name, check_file: true
  end

  def pdf_assertions_doc revision_number, page_number
    pdf_page = @mc.pdf.get_words_on_page page_number: page_number
    assert pdf_page.include?(get_doc_string(revision_number))
  end

  def pdf_assertions_infocard revision_number, page_number
    pdf_page = @mc.pdf.get_words_on_page page_number: page_number
    assert pdf_page.include?(get_infocard_string(revision_number))
  end

  def execution_assertions phase_number, revision_number
    @mc.ebr_navigation.sidenav_navigate_to phase_number
    assert @mc.phase_step.hyperlink_step.get_hyperlink_title.include?(get_doc_string(revision_number))
    assert @mc.phase_step.instructions.get_instruction_text.include?(get_infocard_string(revision_number))
  end

  def get_doc_string revision_number
    "#{@doc_number} (Rev: #{revision_number})"
  end

  def get_infocard_string revision_number
    "#{@infocard_text} (Title: #{@doc_number}, Rev: #{revision_number})"
  end

  def close_current_tab_and_return_to_first_tab
    @mc.close_window
    @mc.use_window 1
  end

  def use_other_tab
    @mc.use_window 2
  end
end
