require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @admin_esig = env['admin_esig']
    @test_mbr = "#{env["simple_mbr_id"]} #{env["simple_mbr_name"]}"
    @lot_1= uniq("Lot1_")
    @lot_2= uniq("Lot2_")

    pre_test
    test_disposition_status_must_be_selected
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_batch_record @test_mbr, @lot_1
    @mc.do.create_batch_record @test_mbr, @lot_2
    fill_out_br @lot_1

    @mc.ebr_navigation.review_by_exception
  end

  def test_disposition_status_must_be_selected
    @mc.review_by_exception.accept_batch
    @mc.review_by_exception.release_batch_record @admin, @admin_esig
    assert wait_until{@mc.reviewandrelease.released_by_info_displayed @admin}
    assert @mc.review_by_exception.dispositioned_status_element.attribute('innerText').include? "Accept"

    fill_out_br @lot_2
    @mc.ebr_navigation.review_by_exception
    sleep 2
    @mc.review_by_exception.reject_batch_element.click
    sleep 2
    @mc.review_by_exception.release_batch_record @admin, @admin_esig
    assert wait_until{@mc.reviewandrelease.released_by_info_displayed @admin}
    assert @mc.review_by_exception.dispositioned_status_element.attribute('innerText').include? "Reject"
  end

  private

  def fill_out_br lot
    @mc.ebr_navigation.go_to_first 'phase', lot
    @mc.batch_phase_step.set_text('some text', '1.1.1.1')

    wait_until do
      @mc.batch_phase_step
         .complete_element
         .visible?
    end

    @mc.phase.completion.complete

    wait_until do
      @mc.batch_phase_step
         .performed_by_element
         .attribute('innerText')
         .include? @admin
    end
  end
end
