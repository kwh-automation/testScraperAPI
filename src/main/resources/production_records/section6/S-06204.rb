require "mastercontrol-test-suite"
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @esig = env["admin_esig"]
    @doc_name = uniq("job_SOP")
    @doc_name_no_uniq = @doc_name[0..-5]
    @job_code = uniq("I_am_Job_Code")

    pre_test
    test_that_phase_information_cannot_be_entered_without_completing_training
    test_that_phase_information_can_be_entered_after_completing_training
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection
    @mc.do.create_document_infocard @doc_name, file_name: resource("small_text"), username: @admin, esig: @esig
    @mc.do.create_course @doc_name, env["test_location"], save: false, verifier_required: "disable"
    @mc.course_infocard.attachments_and_links.add_linked_infocard @doc_name
    @mc.course_infocard.save
    @mc.course_infocard.quick_approve @admin, @esig
    @mc.do.create_job_code @job_code, @doc_name, user_id: @admin, esig: @esig, trainees: @admin, courses: @doc_name
    @mc.go_to.documents
    @mc.documents.search_documents
    @mc.documents.search.for @doc_name
    @mc.documents_list.view_infocard @doc_name, "1"
    @mc.document_infocard.external_link_to_document
    @mc.external_link_to_document.dynamic unless @mc.external_link_to_document.dynamic_element_selected?
    @link = @mc.external_link_to_document.link
    @mc.external_link_to_document.close

    sql_query = "SELECT [info_card_id] FROM [tdc_doc_infocard] WHERE [document_num] LIKE '%#{@doc_name_no_uniq}%'"
    result = @mc.do.run_query(sql_query, print_query: true)
    @linkedDocumentAncestorId = result[0][0]

    phase_json = PhaseFactory.phase_customizer()
                     .with_instructions(
                         PhaseInstructionsBuilder.new.with_notes.with_instruction_part(InstructionPartBuilder.new).build)
                     .with_phase_step(
                         HyperlinkBuilder.new.with_label("#{@doc_name}").with_internal_url(@link).with_order_number(1).with_linkedDocumentAncestorId(@linkedDocumentAncestorId))
                     .with_phase_step(
                         GeneralTextBuilder.new)
                     .build_single_level_master_batch_record
    
    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(phase_json).build

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
  end

  def test_that_phase_information_cannot_be_entered_without_completing_training
    wait_until{ @mc.br_training_required.cancel_element.exists? }
    @mc.br_training_required.cancel
    assert (@mc.phase.phase_steps[1].disabled?), "The phase is enabled, but it should not be."
  end

  def test_that_phase_information_can_be_entered_after_completing_training
    @mc.ebr_navigation.go_to_first("Phase", @lot_number)
    @mc.br_training_required.start_required_training 0
    @mc.use_next_window
    @mc.training_task.sign_off_task
    @mc.sign_off.electronic_signature = @esig
    @mc.sign_off.save
    @mc.do.run_training_gaps
    @mc.use_last_window
    @mc.br_training_required.recheck_training
    wait_until{!@mc.br_training_required.cancel_element.exists?}
    assert !(@mc.phase.phase_steps[1].disabled?), "The phase is not enabled, but it should be."
    @mc.phase.phase_steps[1].set_text 'Training Done'
    @mc.phase.phase_steps[1].blur
    @mc.wait_for_video
  end

end
