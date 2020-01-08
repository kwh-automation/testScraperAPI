require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq("DLA_")
    @product_id = @product_name
    @default_lot_amount = "15"

    pre_test
    test_setting_default_quantity
    test_default_quantity_populates_on_production_record_creation
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
  end

  def test_setting_default_quantity
    @mc.do.create_master_batch_record @product_name, @product_id, default_lot_amount: @default_lot_amount
    @mc.structure_builder.options
    @mc.structure_builder.edit_mbr
    assert @mc.structure_builder.edit_mbr.default_lot_amount_element.attribute("value").include? @default_lot_amount
    @mc.structure_builder.edit_mbr.cancel
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def test_default_quantity_populates_on_production_record_creation
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record "#{@product_id} #{@product_name}"
    assert @mc.batch_record_creation.lot_amount == @default_lot_amount
  end
end
