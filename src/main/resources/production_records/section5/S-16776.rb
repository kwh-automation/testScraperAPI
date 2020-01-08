require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_esig = env["admin_esig"]
    @product_name_prod = uniq("S-16776 Production_")
    @product_name_pilot = uniq("S-16776 Pilot_")
    @product_id_prod = uniq("Prod_", false)
    @product_id_pilot = uniq("Pilot_", false)
    @mt_prod = "#{@product_id_prod} #{@product_name_prod}"
    @mt_pilot = "#{@product_id_pilot} #{@product_name_pilot}"
    @prod = "Production"
    @pilot = "Pilot"
    @connection = MCAPI.new

    pre_test
    test_filter_for_master_template_lifecycle_defaults_to_production
    test_master_template_lifecycle_can_be_filtered_to_pilot_or_production
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_master_batch_record @product_name_prod, @product_id_prod, default_lot_amount: '1', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step 1'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    MCAPIs.approve_MBR @product_name_prod, connection: @connection

    @mc.do.create_master_batch_record @product_name_pilot, @product_id_pilot, default_lot_amount: '1', open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: 'General Text Step 1'
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    @mc.structure_builder.open_infocard_from_structure_builder
    @mc.document_infocard.quick_approve @admin, @admin_esig, "Master Template Pilot"
  end

  def test_filter_for_master_template_lifecycle_defaults_to_production
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    assert @mc.batch_record_creation.lifecycle_label_element.attribute('innerText') == @prod

    @mc.batch_record_creation.master_batch_record_element.click
    assert (@mc.batch_record_creation.master_batch_record_element.attribute('innerHTML').include? @mt_prod)
    assert !(@mc.batch_record_creation.master_batch_record_element.attribute('innerHTML').include? @mt_pilot)
    @mc.batch_record_creation.master_batch_record_element.click
  end

  def test_master_template_lifecycle_can_be_filtered_to_pilot_or_production
    @mc.batch_record_creation.select_lifecycle "Pilot"
    @mc.batch_record_creation.master_batch_record_element.click
    assert (@mc.batch_record_creation.master_batch_record_element.attribute('innerHTML').include? @mt_pilot)
    assert !(@mc.batch_record_creation.master_batch_record_element.attribute('innerHTML').include? @mt_prod)
  end
end
