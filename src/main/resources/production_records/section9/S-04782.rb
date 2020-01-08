require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @document_number = uniq('document', false)

    pre_test
    test_hyperlink_must_be_viewed_before_acknowledging
    test_hyperlink_can_be_viewed
    test_acknowledging_link_viewing
    test_user_data_is_captured_when_acknowledged
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection
    @mc.do.create_document_infocard @document_number

    sql_query = "SELECT [info_card_id] FROM [tdc_doc_infocard] WHERE [document_num] LIKE '%#{@document_number}%'"
    result = @mc.do.run_query(sql_query, print_query: true)
    @linkedDocumentAncestorId = result[0][0]

    mbr_json = PhaseFactory.phase_customizer().
        with_phase_step(HyperlinkBuilder.new.
            with_order_label("1.1.1.1").
            with_order_number(1).
            with_title("hyperlink").
            with_linkedDocumentAncestorId(@linkedDocumentAncestorId)
        ).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(mbr_json).with_lot_number(uniq('lot_')).build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number

    @mc.ebr_navigation.go_to_first('phase', @lot_number)
  end

  def test_hyperlink_must_be_viewed_before_acknowledging
    assert @mc.phase.phase_steps[0].complete_disabled?
    @mc.wait_for_video
  end

  def test_hyperlink_can_be_viewed
    @mc.phase.phase_steps[0].view_link
    @mc.use_window 2
    @mc.close_window
    @mc.use_window 1
  end

  def test_acknowledging_link_viewing
    @mc.phase.phase_steps[0].complete
  end

  def test_user_data_is_captured_when_acknowledged
    step_date_correct = @mc.do.check_time(@mc.phase.phase_steps[0].date)
    step_performer_correct = @mc.phase.phase_steps[0].performer.include? @admin.downcase
    assert step_performer_correct
    assert step_date_correct
  end
end

