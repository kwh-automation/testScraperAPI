require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_attachment_step_displays_title
    test_attachment_displays_in_appendix
  end

  def pre_test
    connection = MCAPI.new
    MCAPIs.approve_trainees @admin, connection: connection
    @mc.do.login @admin, @admin_pass

    @order_label = "1.1.1.1"


    @file_to_upload = "#{env['resource_dir']}/eBRLabsInc.png"

    mbr_json = PhaseFactory.phase_customizer().
        with_phase_step(AttachmentBuilder.new.
            with_order_label(@order_label).
            with_order_number(1).
            with_title("Attachment")
        ).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                            .with_master_batch_record_json(mbr_json)
                            .with_lot_number(uniq('lot_', false))
                            .with_connection(connection)
                            .build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number

    @mc.ebr_navigation.go_to_first('phase', @lot_number)
  end

  def test_attachment_step_displays_title
    attachment_phase_step = @mc.phase.phase_steps[0]
    attachment_phase_step.attach(@file_to_upload)
    wait_until{attachment_phase_step.attached?}
    @attachment_filename = @mc.phase.phase_steps[0].get_name_of_uploaded_file
    @mc.do.move_downloaded_files "", "pdf"
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
    @mc.hide_window

    assert @mc.pdf.find_text @attachment_filename
  end

  def test_attachment_displays_in_appendix
    assert @mc.pdf.find_appendix_attachment(@attachment_filename)
    @mc.wait_for_video
  end

  def clean_up
    @mc.pdf.close
  end
end