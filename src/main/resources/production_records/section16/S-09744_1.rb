require "mastercontrol-test-suite"

class FTErpConfiguration < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env["password"]
    @erp_address = "http://mcusdevmfg.mainman.dcs:8082"
    @erp_token = "123456789"

    pre_test
    test_user_can_enter_erp_configuration_basic_auth
    test_user_can_enter_erp_configuration_bearer_token
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr.erp_configuration
  end

  def test_user_can_enter_erp_configuration_basic_auth
    @mc.erp_settings.erp_address = @erp_address
    @mc.erp_settings.authentication = "Basic Authentication"
    @mc.erp_settings.erp_basic_auth username: "testing", pass: "TESTING"
    @mc.erp_settings.test_connection
    assert @mc.erp_settings.connection_success?
    @mc.erp_settings.save
  end

  def test_user_can_enter_erp_configuration_bearer_token
    @mc.ebr.erp_configuration
    @mc.erp_settings.authentication = "Bearer Token"
    @mc.erp_settings.bearer_token = @erp_token
    @mc.erp_settings.test_connection
    assert @mc.erp_settings.connection_success?
    @mc.erp_settings.save
  end

end