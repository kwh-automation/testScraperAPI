require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq("7127")
    @product_id = uniq("prod_id")
    @product_name = uniq("name")
    @production_user = uniq("Prod_user")
    @sign_off_user = uniq("sign_off_user")
    @esig = env["admin_esig"]
    @connection = MCAPI.new(env['sysadmin'], env["sysadmin_password"])

    pre_test
    test_configuring_operation_sign_off
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    MCAPIs.create_user @production_user, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @sign_off_user, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@production_user, @sign_off_user], esig: env["sysadmin_esig"], connection: @connection

    @mc.ebr.open_new_mbr_structure @product_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit_with_sign_offs set_name: "Unit procedure 1"
  end

  def test_configuring_operation_sign_off
    @mc.structure_builder.operation_level.add_unit_with_sign_offs set_name: "Operation 1", has_first_sign_off: true, has_second_sign_off: true
  end
end