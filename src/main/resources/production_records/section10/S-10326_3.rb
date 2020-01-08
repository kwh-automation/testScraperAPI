# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('product_')
    @product_id = uniq('id_')
    @authorized = uniq('authorized_')
    @restricted = uniq('restricted_')
    @lot = uniq('authorized_')
    @user_rights = { 'Production Records': ['Production Operator',
                                            'Configuration Tile',
                                            'Create Production Record',
                                            'Form Launch',
                                            'Manage Master Template',
                                            'Supervisor Override',
                                            'View Production Workspace'],
                     Process: ['Start Task'] }

    pre_test
    test_unauthorized_role_cant_enter_data
    test_authorized_role_can_enter_data
  end

  def pre_test
    @connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_role @authorized, @admin, application_rights_hash: @user_rights, vaults: 'all'
    @mc.do.create_role @restricted, @admin, application_rights_hash: @user_rights, vaults: 'all'
    MCAPIs.create_user @authorized, roles: @authorized, connection: @connection
    MCAPIs.create_user @restricted, roles: @restricted, connection: @connection
    create_batch_record
    @mc.go_to.ebr
  end

  def test_unauthorized_role_cant_enter_data
    switch_browser_context(@restricted)
    @mc.do.login @restricted, @admin_pass, approve_trainee: true, connection: @connection
    @mc.ebr_navigation.go_to_first 'phase', @lot
    @mc.phase.phase_steps[0].set_text uniq('text-', false)
    @mc.phase.phase_steps[0].blur wait_for_completion: false
    assert @mc.phase.phase_steps[0].is_not_in_role?
  end

  def test_authorized_role_can_enter_data
    switch_browser_context(@auhtorized)
    @mc.do.login @authorized, @admin_pass, approve_trainee: true, connection: @connection
    @mc.ebr_navigation.go_to_first 'phase', @lot, view_all_tab: true
    @mc.phase.phase_steps[0].autocomplete
    assert !@mc.phase.phase_steps[0].captured_value.to_s.empty?
  end

  private

  def create_batch_record
    authorized_id = MCAPIs.get_role_id_by_role_name(@authorized, connection: @connection)
    custom_phase = PhaseFactory
                       .phase_customizer
                       .with_phase_step(GeneralTextBuilder
                                            .new
                                            .with_notes
                                            .with_order_number(1)
                                            .with_authorized_role_id(authorized_id))
                       .with_order_number(1)
                       .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                            .with_master_batch_record_json(custom_phase)
                            .with_lot_number(@lot)
                            .with_connection(@connection)
                            .build

    @lot += '_1'
  end
end
