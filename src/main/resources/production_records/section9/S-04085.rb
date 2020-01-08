require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_adding_an_attachment
    test_downloading_uploaded_file
    test_that_attachment_performer_populates_after_click
  end
  
  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection
   
    @file_to_upload = "#{env['resource_dir']}/eBRLabsInc.png"
    
    mbr_json = PhaseFactory.phase_customizer()
                   .with_phase_step(AttachmentBuilder.new.with_title("Attachment Notifications Test"))
                   .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                            .with_master_batch_record_json(mbr_json)
                            .with_lot_number(uniq("Lot/;<>Number?", false))
                            .with_connection(connection)
                            .build

    batch_record = @test_environment.master_batch_records[0].batch_records[0]
    @mc.do.navigate_to_first "phase", batch_record.lot_number
  end


  def test_adding_an_attachment
    @mc.phase.phase_steps[0].attach(@file_to_upload)
    wait_until{@mc.phase.phase_steps[0].attached?}
    uploaded_file_link_available = @mc.phase.phase_steps[0].attached?
    assert uploaded_file_link_available
  end

  def test_downloading_uploaded_file
    @mc.phase.phase_steps[0].download
    downloaded_filename = @mc.phase.phase_steps[0].get_name_of_uploaded_file
    downloaded_filename = downloaded_filename.gsub(/\s+/, "")
    file = get_file_downloads_path downloaded_filename
    assert wait_until{ File.exist?(file)}
  end

  def test_that_attachment_performer_populates_after_click
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[0].date)
    step_performer_correct = @mc.phase.phase_steps[0].performer.include? @admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end
end