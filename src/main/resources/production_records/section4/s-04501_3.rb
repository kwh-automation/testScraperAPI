require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04501_", false)
    @product_id = uniq("1", false)

    pre_test
    test_each_data_type_can_be_further_configured_using_data_type_properties
    test_character_limits_property_can_be_added_to_the_general_text_data_type
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block "1", text:"Generic Text Step 1"
  end

  def test_each_data_type_can_be_further_configured_using_data_type_properties
    @mc.phase_step.general_text.enable_suggested_entry
    @mc.phase_step.general_text.enable_character_limits
    @mc.phase_step.general_text.enable_completion_notification
    @mc.phase_step.general_text.enable_verification
    @mc.phase_step.general_text.enable_witness
    @mc.phase_step.general_text.enable_notes
    assert @mc.phase_step.general_text.is_notes_enabled?
    assert @mc.phase_step.general_text.is_witness_enabled?
    assert @mc.phase_step.general_text.is_verification_enabled?
    assert @mc.phase_step.general_text.is_corrections_enabled?
    assert @mc.phase_step.general_text.is_completion_notification_enabled?
    assert @mc.phase_step.general_text.is_character_limits_enabled?
    assert @mc.phase_step.general_text.is_suggested_entries_enabled?
  end

  def test_character_limits_property_can_be_added_to_the_general_text_data_type
    assert @mc.phase_step.general_text.is_character_limits_enabled?
    @mc.phase_step.general_text.edit_character_minimum_limit "10"
    @min_character_value = @mc.phase_step.general_text.character_limits_minimum_value_element.attribute('value')
    @mc.phase_step.general_text.edit_character_maximum_limit "20"
    @max_character_value = @mc.phase_step.general_text.character_limits_maximum_value_element.attribute('value')
    assert @mc.phase_step.general_text.character_limit_display_element.attribute('innerText').include?("#{@min_character_value} - #{@max_character_value} Characters")
  end

end
