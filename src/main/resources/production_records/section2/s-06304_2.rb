require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @new_reason = uniq("new_reason", false)

    pre_test
    test_add_correction_to_correction_reason_list_page
    test_new_reason_is_in_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
  end

  def test_add_correction_to_correction_reason_list_page
    @mc.ebr.view_all_correction_reasons
    @mc.correction_reason_list.add_correction_reason @new_reason
    @mc.correction_reason_list.filter_reason_name @new_reason
    assert @mc.correction_reason_list.correction_reason_exists?(@new_reason), "Reason does not exist."
  end

  def test_new_reason_is_in_master_template
    @mc.do.create_master_batch_record uniq("#{@admin}", false), uniq("1", false), open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_correction_reason if @mc.phase_step.general_text.is_corrections_enabled?
    @mc.phase_step.reason_toolbar
    @mc.phase_step.general_text.choose_correction_reason @new_reason
  end

end