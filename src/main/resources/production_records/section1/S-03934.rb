# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('lot_', false)
    @lot_one = @lot_number + '_1'
    @lot_two = @lot_number + '_2'
    @first_phase_title = uniq('First Phase ')
    @second_phase_title = uniq('Second Phase ')
    @third_phase_title = uniq('Third Phase ')

    pre_test
    test_users_can_see_active_phases_matching_their_work_history
    test_users_can_navigate_matching_open_phases
  end

  def pre_test
    @connection = MCAPI.new
    create_batch_record
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
  end

  def test_users_can_see_active_phases_matching_their_work_history
    @mc.ebr_navigation.go_to_first 'phase', @lot_one, custom_name: @first_phase_title
    @mc.phase.phase_steps[0].autocomplete

    @mc.ebr_navigation.go_to_phase @lot_one, 3, custom_name: @third_phase_title
    @mc.phase.phase_steps[0].autocomplete

    @mc.go_to.ebr
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_one
    @mc.ebr_navigation.open_jobs

    wait_until { @mc.batchrecordjobsearch.get_open_jobs_results_size >= 1 }
    open_job_titles = @mc.batchrecordjobsearch.get_open_job_titles

    assert open_job_titles.length == 2
    assert open_job_titles[0].include? @first_phase_title
    assert open_job_titles[1].include? @third_phase_title
  end

  def test_users_can_navigate_matching_open_phases
    @mc.batchrecordjobsearch.go_to_open_job 0
    wait_until { @mc.ebr_navigation.header_text.include? @first_phase_title }

    @mc.go_to.ebr
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_two
    @mc.ebr_navigation.open_jobs
    wait_until { @mc.batchrecordjobsearch.get_open_jobs_results_size >= 1 }
    @mc.batchrecordjobsearch.go_to_open_job 1
    wait_until { @mc.ebr_navigation.header_text.include? @third_phase_title }
    assert @mc.ebr_navigation.header_text.include? @third_phase_title
  end

  private

  def create_batch_record
    first_phase = PhaseFactory.phase_customizer
                              .with_title(@first_phase_title)
                              .with_order_label('1.1.1')
                              .with_phase_step(GeneralTextBuilder.new.with_witness.build)
                              .build

    second_phase = PhaseFactory.phase_customizer
                               .with_title(@second_phase_title)
                               .with_order_label('1.1.2')
                               .with_phase_step(GeneralTextBuilder.new.build)
                               .build

    third_phase = PhaseFactory.phase_customizer
                              .with_title(@third_phase_title)
                              .with_order_label('1.1.3')
                              .with_phase_step(GeneralTextBuilder.new.with_verification.build)
                              .build

    mbr_json = MasterBatchRecordBuilder.new
                                       .with_unit_procedure(UnitProcedureBuilder.new
                                            .with_operation(OperationBuilder.new
                                                                .with_phase(first_phase)
                                                                .with_phase(second_phase)
                                                                .with_phase(third_phase)
                                                                .build).build).build

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_connection(@connection)
                                                 .with_master_batch_record_json(mbr_json)
                                                 .with_batch_records_per_master_batch_record(2)
                                                 .with_lot_number(@lot_number)
                                                 .build
  end
end
