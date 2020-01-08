require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @eBR = "Production Records"

    pre_test
    test_navigate_to_production_hub_from_my_mastercontrol
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
  end

  def test_navigate_to_production_hub_from_my_mastercontrol
    @mc.go_to.my_mc.ebr_hub
    wait_until { @mc.ebr.main_title_element.visible? }
    assert (@mc.ebr.main_title_element.attribute("innerHTML").include? @eBR)
  end

end
