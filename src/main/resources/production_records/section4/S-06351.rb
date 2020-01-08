require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @doc_number = uniq("doc_")
    @mbr_name = uniq("S-06351_")
    @pid_number = uniq("6351_")
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_linking_mastercontrol_document_via_search_in_hyperlink_setup
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc_number, username: @admin, esig: env["admin_esig"]
    @mc.ebr.open_new_mbr_structure @mbr_name, @pid_number
    @sb = @mc.structure_builder
    @mc.edit_mbr.select_release_role
    @sb.edit_mbr._next
    @sb.edit_mbr.header_settings.save
    @sb.procedure_level.add_unit set_name: @doc_number
    @sb.operation_level.add_unit set_name: @doc_number
    @sb.phase_level.add_unit set_name: @doc_number
    @sb.phase_level.settings 1
    @sb.phase_level.open_phase_builder 1
  end

  def test_linking_mastercontrol_document_via_search_in_hyperlink_setup
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step_hyperlink.add_document_to_hyperlink @doc_number
    assert wait_until { @mc.phase_step.is_document_linked? @doc_number }
  end

end
