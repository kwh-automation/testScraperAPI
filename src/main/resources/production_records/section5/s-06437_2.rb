require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_esig = env["admin_esig"]
    @product_name = uniq("S06437", false)
    @product_id = uniq("1", false)
    @numbering_series = uniq("MBR_NS", false)

    pre_test
    test_production_records_can_only_be_created_from_master_templates_that_are_on_infocards_in_a_released_vault
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_numbering @numbering_series, available_to: "Production Records"
    @mc.go_to.documents.new_document
    @mc.add_new_document.select_infocard_type "Master Template"
    @mbr_num = @mc.document_infocard.information.document_number
    @mc.document_infocard.cancel
    @mc.ebr.open_new_mbr_structure @product_name, @product_id, lot_number_configuration: @numbering_series
    assert @mc.structure_builder.edit_mbr.lot_number_configuration_element.item_selected?(@numbering_series)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "1_Procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "1_Operation"
    @mc.structure_builder.phase_level.add_unit set_name: "1_Phase"
    @mc.structure_builder.publish_mbr_from_structure_builder
  end

  def test_production_records_can_only_be_created_from_master_templates_that_are_on_infocards_in_a_released_vault
    @mc.go_to.documents.view_documents
    @mc.documents_list.search.simple.search_for = @product_name
    @mc.documents_list.search.submit_search
    @mc.documents_list.view_infocard @mbr_num, "A"
    @mc.document_infocard.quick_approve @admin, @admin_esig, "Master Template Pilot"
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.select_lifecycle "Pilot"
    @mc.batch_record_creation.master_batch_record_element.click
    assert (@mc.batch_record_creation.master_batch_record_element.attribute('innerHTML').include?("#{@product_id} #{@product_name}"))
    @mc.batch_record_creation.master_batch_record "#{@product_id} #{@product_name}"
  end
end
