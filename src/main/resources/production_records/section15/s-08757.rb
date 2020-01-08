require "mastercontrol-test-suite"
class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @lot_number = uniq("Lot_", false)
    @string = uniq("Test text ")
    @test_mbr = "#{env["mbr_product_id"]} #{env["mbr_product_name"]}"

    pre_test
    test_redacted_pdf
    test_pdf_for_sections_excluded
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_batch_record @test_mbr, @lot_number

    @mc.ebr_navigation.go_to_first("phase", @lot_number)
  end

  def test_redacted_pdf
    @mc.do.move_downloaded_files "", "pdf"
    @mc.ebr_navigation.options_dropdown
    @mc.ebr_navigation.redacted
    @mc.ebr_navigation.export_pdf_option 3
    @mc.ebr_navigation.export_pdf
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
  end

  def test_pdf_for_sections_excluded
    assert @mc.pdf.find_text("Unit Procedure 1")
    assert @mc.pdf.find_text("Section 1.1 has been intentionally omitted")
    assert @mc.pdf.find_text("iterative_operation")
    assert @mc.pdf.find_text(@lot_number)
  end

  def clean_up
    @mc.pdf.close
  end

end