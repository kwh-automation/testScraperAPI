require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @name = uniq("Product_")
    @prod_id = uniq("Id")
    @lot_number = uniq('Lot_')
    @test_mbr = "#{@prod_id} #{@name}"
    @rev = '0'
    @quantity = 3
    @connection = MCAPI.new

    pre_test
    test_batch_record_header_shows_the_master_template_product_id_revision_lot_number_initiation_date_and_quantity
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    create_mbr
    @mc.ebr_navigation.go_to_first 'Phase', @lot_number + "_1"
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.completion.complete
  end

  def test_batch_record_header_shows_the_master_template_product_id_revision_lot_number_initiation_date_and_quantity
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_number + "_1"

    assert @mc.accountability.mbr_name_element.attribute('innerText').include? @name
    assert @mc.accountability.product_id_element.attribute('innerText').include? @prod_id
    assert @mc.accountability.mbr_revision_element.attribute('innerText').include? @rev
    assert @mc.accountability.lot_number_element.attribute('innerText').include? @lot_number
    assert @mc.do.check_time(@mc.accountability.initiation_date_element.attribute('innerText'))
    assert @mc.accountability.lot_amount_element.attribute('innerText').include? @quantity.to_s
  end

  private

  def create_mbr
    custom_phase = PhaseFactory
                       .phase_customizer()
                       .with_phase_step(GeneralTextBuilder
                                            .new
                                            .with_notes
                                            .with_order_number(1)
                                            .with_maximum_length(120)
                                            .build)
                       .with_order_number(1)
                       .build

    test_mt = MasterBatchRecordBuilder.new
                  .with_revision_number(@rev)
                  .with_product_name(@name)
                  .with_product_id(@prod_id)
                  .with_unit_procedure(UnitProcedureBuilder
                                           .new
                                           .with_operation(OperationBuilder
                                                               .new.with_phase(custom_phase)
                                                               .build)
                                           .build)
                  .build

    @test_environment = EbrTestEnvironmentBuilder.new
                            .with_master_batch_record_json(test_mt)
                            .with_lot_number(@lot_number)
                            .with_quantity(@quantity)
                            .with_connection(@connection)
                            .build
  end
end
