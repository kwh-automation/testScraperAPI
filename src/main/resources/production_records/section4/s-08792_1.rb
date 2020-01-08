require "mastercontrol-test-suite"

class TestLinks < MCValidationTest
  include Ebr
  
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @infocard_text = uniq("infocard", false)
    @custom_link = "custom"
    @prod_name = uniq("s05956_", false)
    @prod_id = uniq("1", false)
    @doc = uniq("s-08792")
    @lot_number = uniq("Lot")
    @custom_link_url = "https://www.google.com"

    pre_test
    test_that_links_to_document_infocards_can_be_added_to_instructions
    test_that_custom_links_can_be_added_to_instructions
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc, file_name: resource("small_text")
    @mc.infocard.quick_approve env['password'], env['admin_esig']
    @mc.do.create_master_batch_record @prod_name, @prod_id, open_phase_builder: true
    wait_until { @mc.phase_step._add_instruction_element.visible? }
    @mc.phase_step.add_general_text
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @infocard_text + "  " + @custom_link
  end

  def test_that_links_to_document_infocards_can_be_added_to_instructions
    @infocard_link = (@mc.phase_step.instructions.add_infocard_link @infocard_text, @doc)
    @infocard_id = @infocard_link.match(/(ID%.+?%)|(ID%.+?.*)/)[0]
    assert @mc.phase_step.link_in_textfield_begins_with_value @infocard_link
  end

  def test_that_custom_links_can_be_added_to_instructions
    @mc.phase_step.instructions.add_hyperlink @custom_link, @custom_link_url
    assert @mc.phase_step.link_in_textfield_element.exists?
  end

end
