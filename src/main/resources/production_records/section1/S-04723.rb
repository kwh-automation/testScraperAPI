require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']

    pre_test

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @product_name = @test_environment.master_batch_records[0].product_name

    test_entering_a_lot_number_navigates_to_top_level_accountability_page
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection
    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).build
  end

  def test_entering_a_lot_number_navigates_to_top_level_accountability_page
    @mc.go_to.ebr
    @mc.ebr.batch_record_search_input = @lot_number
    @mc.ebr.batch_record_go
    wait_until{ @mc.ebr_navigation.on_procedure_page? }
    @mc.ebr_navigation.go_to_accountability
    wait_until{ @mc.accountability.verify_lot_number(@lot_number) }
  end

end