require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @infocard_text = uniq("infocard", false)
    @custom_link = uniq("custom", false)
    @prod_name = uniq("s05956_", false)
    @prod_id = uniq("1", false)
    @doc = uniq("s-08792")
    @lot_number = uniq("Lot")
    @infocard_link = ""
    @custom_link_url = "https://www.google.com"

    pre_test
    test_that_url_is_connected_for_pdf
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc, file_name: resource("small_text")
    @mc.infocard.quick_approve env['password'], env['admin_esig']
    @mc.do.create_master_batch_record @prod_name, @prod_id, open_phase_builder: true
    wait_until { @mc.phase_step._add_instruction_element.visible? }
    @mc.phase_step.add_general_text
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text "#{@infocard_text} #{@custom_link}"
    @infocard_link = @mc.phase_step.instructions.add_infocard_link(@infocard_text, @doc)
    @infocard_id = @infocard_link.match(/(ID%.+?%)|(ID%.+?.*)/)[0]
    assert @mc.phase_step.link_in_textfield_contains_value @infocard_id
    @mc.phase_step.instructions.add_hyperlink @custom_link, @custom_link_url
    assert @mc.phase_step.link_in_textfield_element.exists?
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @prod_name, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_name}", @lot_number
  end

  def test_that_url_is_connected_for_pdf
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.do.move_downloaded_files "", "pdf"
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name, check_file: true
    pdf_page = (@mc.pdf.get_words_on_page).delete(' ')
    assert pdf_page.include?(@infocard_text)
    assert pdf_page.include?(@custom_link)

  end

  def clean_up
    @mc.pdf.close
  end
end
