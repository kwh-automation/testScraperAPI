require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @authorized = uniq("authorized_")
    @authorized_2 = uniq("authorized_2_")
    @restricted = uniq("restricted_")
    @admin = env["admin_user"]
    @password = env["password"]
    @mbr = uniq("authorized_")
    @id = uniq("roles_")
    @user_rights = {"Production Records": ["Production Operator",
                                 "Configuration Tile",
                                 "Create Production Record",
                                 "Form Launch",
                                 "Manage Master Template",
                                 "Supervisor Override",
                                 "View Production Workspace"],
                    Process: ["Start Task"]}

    pre_test
    test_authorized_roles_can_be_configured_on_a_phase_step
    test_that_one_or_more_roles_can_be_selected
  end

  def pre_test
    @mc.do.login @admin, @password, approve_trainee: true
    @mc.do.create_role @authorized, @admin, application_rights_hash: @user_rights, vaults: 'all'
    @mc.do.create_role @authorized_2, @admin, application_rights_hash: @user_rights, vaults: 'all'
    @mc.do.create_role @restricted, @admin, application_rights_hash: @user_rights, vaults: 'all'
    @mc.do.create_master_batch_record @mbr, @id, open_phase_builder: true

    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block 1, text:"Date Step"
  end

  def test_authorized_roles_can_be_configured_on_a_phase_step
    @mc.phase_step.numeric_data.enable_authorized_roles
    assert @mc.phase_step.is_tag_added? "date", 1, "authorized-roles"
    assert @mc.phase_step.numeric_data.is_authorized_roles_enabled?
  end

  def test_that_one_or_more_roles_can_be_selected
    @mc.phase_step.numeric_data.authorized_roles_toolbar
    @mc.phase_step.numeric_data.choose_authorized_role @authorized
    @mc.phase_step.numeric_data.choose_authorized_role @authorized_2
  end

end