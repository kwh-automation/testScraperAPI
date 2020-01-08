require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04779_", false)
    @product_id = uniq("1", false)
    @suggested_entries = ["test 1", "test 2", "test 3"]

    pre_test
    test_add_suggested_entry
    test_suggested_entry_autocomplete_with_custom_entry

  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
  end

  def test_add_suggested_entry
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.settings "1"
    @mc.phase_step.general_text.add_suggested_entry text:@suggested_entries[0]
    @mc.phase_step.general_text.add_suggested_entry text:@suggested_entries[1]
    @mc.phase_step.general_text.add_suggested_entry text:@suggested_entries[2]
    assert @mc.phase_step.general_text.is_suggested_entry_tag_added?("1")
    @mc.phase_step.general_text.suggested_entry_in_list?("1.1.1.1", @suggested_entries)
  end

  def test_suggested_entry_autocomplete_with_custom_entry
    @mc.phase_step.general_text.choose_selected_entry "1.1.1.1", value:"st 3"
  end

end
