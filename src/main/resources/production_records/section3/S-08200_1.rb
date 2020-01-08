require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @test_mbr = env['mbr_product_name']
    @test_mbr_id = env['mbr_product_id']
    @file_name = "#{@test_mbr}-#{@test_mbr_id}"

    pre_test
    test_exporting_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.move_downloaded_files "#{@file_name}", "mt"
  end

  def test_exporting_master_template
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.open_filter
    @mc.master_batch_record_list.filter_product_name @test_mbr
    @mc.master_batch_record_list.filter_product_id @test_mbr_id
    @mc.master_batch_record_list.master_batch_record_filter_apply
    @mc.master_batch_record_list.close_filter
    @mc.master_batch_record_list.export_mbr @test_mbr_id
    file = File.expand_path "#{ENV['USERPROFILE']}/downloads/#{@file_name}.mt"
    assert wait_until{File.exist?(file)}
    @mc.wait_for_video
  end

  def clean_up
    @mc.do.move_downloaded_files "#{@file_name}", "mt"
  end

end