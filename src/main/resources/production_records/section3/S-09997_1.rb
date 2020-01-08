require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mt_name = uniq("enable_")
    @prod_id = uniq("looping_")

    pre_test
    test_enabling_looping_operations_in_structure_builder
    test_enabling_looping_operations_is_persisted
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @mt_name, @prod_id
  end

  def test_enabling_looping_operations_in_structure_builder
    @mc.structure_builder.operation_level.select_unit 1
    @mc.structure_builder.operation_level.settings 1
    @mc.structure_builder.operation_level.enable_repeatable
    assert @mc.structure_builder.operation_level.repeatable?
    @mc.structure_builder.operation_level.save
  end

  def test_enabling_looping_operations_is_persisted
    @mc.refresh
    @mc.structure_builder.operation_level.select_unit 1
    @mc.structure_builder.operation_level.settings 1
    assert @mc.structure_builder.operation_level.repeatable?
    @mc.structure_builder.operation_level.cancel
  end

end