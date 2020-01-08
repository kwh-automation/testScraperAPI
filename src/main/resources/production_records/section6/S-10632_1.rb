require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @connection = MCAPI.new
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_esig = env['admin_esig']
    @admin_role = env['test_admin_role']
    @witness_user = uniq("witness_")
    @verify_user = uniq("verify_")
    @vo_user = uniq("view_only_", false)
    @vo_role = uniq("view_only_")
    @first_value = "abc"
    @second_value = "xyz"
    @user_rights = {"Production Records": ["Production Operator",
                    "Configuration Tile",
                    "Create Production Record",
                    "Form Launch",
                    "Manage Master Template",
                    "Supervisor Override",
                    "View Production Workspace"],
                    Process: ["Start Task"]}


    pre_test
    test_user_cannot_witness_and_verify_if_not_in_authorized_role
    test_user_can_witness_and_verify_in_authorized_role
  end

  def pre_test
    @mc.do.login @admin, @admin_pass
    MCAPIs.create_user @witness_user, esig: env["admin_esig"], roles: env["test_admin_role"], connection: @connection
    MCAPIs.create_user @verify_user, esig: env["admin_esig"], roles: env["test_admin_role"], connection: @connection
    MCAPIs.create_user @vo_user, esig: env["admin_esig"], roles: env["test_admin_role"], connection: @connection
    @mc.do.create_role @vo_role, @vo_user, application_rights_hash: @user_rights, vaults: 'all'
    MCAPIs.delete_user_from_role @vo_user, @admin_role, connection: @connection
    MCAPIs.approve_trainees [@admin, @witness_user, @verify_user, @vo_user], connection: @connection

    build_mbr

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @mc.ebr_navigation.go_to_lot @lot_number
    @mc.ebr_navigation.go_to_first "phase", @lot_number, view_all_tab: true
  end

  def test_user_cannot_witness_and_verify_if_not_in_authorized_role
    @step_1 = @mc.phase.phase_steps[0]

    @step_1.set_text @first_value
    @step_1.blur

    @step_1.witness.username.send_keys @vo_user
    @step_1.witness.esignature.send_keys @admin_esig
    @step_1.witness.submit
    wait_until(5) { @step_1.witness.is_not_in_role? }
    @step_1.witness.username.clear
    @step_1.witness.esignature.clear
  end

  def test_user_can_witness_and_verify_in_authorized_role
    @step_1.witness.username.send_keys @witness_user
    @step_1.witness.esignature.send_keys @admin_esig
    @step_1.witness.submit
    wait_until{@step_1.witness.performer != ""}
    assert @step_1.witness.performer? @witness_user

    @step_1.verification.username.send_keys @verify_user
    @step_1.verification.esignature.send_keys @admin_esig
    @step_1.verification.submit
    wait_until{@step_1.verification.performer != ""}
    assert @step_1.verification.performer? @verify_user

  end

  private

  def get_role_id role_name
    sql_query = "SELECT [role_id] FROM [portal_role] WHERE [role_name] = N'#{role_name}'"
    result = @mc.do.run_query(sql_query, print_query: true)
    result[0][0]
  end

  def build_mbr

    admin_role_id = get_role_id(@admin_role)
    view_role_id = get_role_id(@vo_role)


    mbr_json = PhaseFactory.phase_customizer()
                   .with_phase_step(GeneralTextBuilder.new
                                        .with_order_number(1)
                                        .with_witness(AuthorizedRolesConfigurationBuilder.new
                                                                                         .with_witness_roles(admin_role_id)
                                                                                         .build
                                        )
                                        .with_verification(AuthorizedRolesConfigurationBuilder.new
                                                                                              .with_verification_roles(admin_role_id)
                                                                                              .build
                                        )
                   )
                   .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_master_batch_record_json(mbr_json).with_connection(@connection).build

  end

end
