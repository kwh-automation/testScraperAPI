require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_esig = env["admin_esig"]
    @product_name = uniq("reviseMT")
    @product_id = uniq("S-07451")
    @mbr_name = "#{@product_name}-#{@product_id}"

    pre_test
    test_revising_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def test_revising_master_template
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by :product_id, @product_id
    @mc.master_batch_record_list.revise_master_batch_record @product_id
    assert @mc.master_batch_record_list.in_list? @product_id
    @mc.go_to.documents.search_documents
    @mc.documents_list.search.advance_search "Title", "Contains", @mbr_name
    assert (@mc.documents_list.get_document_infocard_vault @mbr_name, "B").include?("Master Template Draft")
  end

end
