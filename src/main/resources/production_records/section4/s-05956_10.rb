require "mastercontrol-test-suite"

class FTS04463 < MCFunctionalTest
#EBR FRS Section 2.1

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @instruction_text = uniq("Test", false)
    @prod_name = uniq("s05956_", false)
    @prod_id = uniq("1", false)
    @custom_url = "https://www.google.com"

    pre_test
    test_adding_instructions_to_phase_builder
    test_phase_instructions_can_include_links
    test_phase_instructions_can_contain_photos
    test_field_notes_can_be_added_to_instructions
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @prod_name, @prod_id, open_phase_builder: true
  end

  def test_adding_instructions_to_phase_builder
    wait_until { @mc.phase_step._add_instruction_element.visible? }
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @instruction_text
    assert @mc.phase_step.instructions._editor_field_element.text.include? "#{@instruction_text}"
  end

  def test_phase_instructions_can_include_links
    @mc.phase_step.instructions.add_hyperlink @instruction_text, @custom_url
    assert @mc.phase_step.link_in_textfield_begins_with_value @custom_url
    @mc.phase_step.instructions.clear_instructions
  end

  def test_phase_instructions_can_contain_photos
    @mc.phase_step.instructions.add_image resource("jpg_image")
    assert @mc.phase_step.image_inline_element.exists?
    @mc.phase_step.instructions
  end

  def test_field_notes_can_be_added_to_instructions
    @mc.phase_step.instructions.add_instruction_text "text"
    @mc.phase_step.instructions.enable_notes
    wait_until { @mc.phase_step.instructions.is_notes_enabled? }
    assert @mc.phase_step.instructions.is_notes_enabled?
  end
end
