require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_rendering_of_master_template_pdf
    test_displaying_page_x_of_y_on_master_template_pdf
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass
    MCAPIs.approve_trainees @admin, connection: connection

    @unit_procedure_name = "Unit Procedure"
    @operation_name = "Operation"
    @phase_name = "Phase"
    @phase_step_name = "Phase Step"

    @unique_product = uniq('S-02401', false)

    @test_environment = EbrTestEnvironmentBuilder.new
                          .with_product_id(@unique_product)
                          .with_product_name(@unique_product)
                          .with_unit_procedure_name(@unit_procedure_name)
                          .with_operation_name(@operation_name)
                          .with_phase_name(@phase_name)
                          .with_batch_records_per_master_batch_record(0)
                          .with_connection(connection)
                          .build
  end

  def test_rendering_of_master_template_pdf
    @mc.do.move_downloaded_files "", "pdf"
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by(:product_id, @unique_product)
    @mc.master_batch_record_list.view_pdf @unique_product
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
    @mc.hide_window
    @mc.wait_for_video
    assert @mc.pdf.find_text(@unique_product)
  end

  def test_displaying_page_x_of_y_on_master_template_pdf
    total_pages = @mc.pdf.get_total_pages
    page_x_of_y_display_text = "Page 1 of " + total_pages.to_s
    assert @mc.pdf.find_text(page_x_of_y_display_text)
    @mc.wait_for_video
  end

  def clean_up
    @mc.pdf.close
  end
  
end