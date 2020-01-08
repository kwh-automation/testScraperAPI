require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_esig = env["admin_esig"]
    @product_name1 = uniq("S06437_1", false)
    @product_id1 = uniq("1", false)
    @product_name2 = uniq("S06437_2", false)
    @product_id2 = uniq("1", false)
    @mbr_infocard1 = "#{@product_name1}-#{@product_id1}"
    @mbr_infocard2 = "#{@product_name2}-#{@product_id2}"

    pre_test
    test_master_template_can_be_published
    test_pdf_rendering_is_attached_to_a_master_template_infocard
    test_publishing_versions_the_master_template_infocard
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
  end

  def test_master_template_can_be_published
    @mc.do.create_master_batch_record @product_name1, @product_id1
    @mc.structure_builder.publish_mbr_from_structure_builder
    @mc.success.displayed?
    @mc.do.create_master_batch_record @product_name2, @product_id2
    @mc.structure_builder.publish_mbr_from_structure_builder
    @mc.success.displayed?
  end

  def test_pdf_rendering_is_attached_to_a_master_template_infocard
    @mc.go_to.documents.view_documents
    @mc.documents_list.search.basic.title = @mbr_infocard1
    @mc.documents_list.search.search
    @mc.documents_list.view_first_infocard
    file = @mc.document_infocard.information.readonly_main_file
    assert(file == "#{@mbr_infocard1}.pdf")
  end

  def test_publishing_versions_the_master_template_infocard
    assert (doc_infocard_number_incremented? @product_name1, @product_name2)
  end

  private
  def doc_infocard_number_incremented? first_infocard, second_infocard
    @mc.go_to.documents.view_documents
    @mc.documents_list.search.basic.title = first_infocard
    @mc.documents_list.search.search
    @mc.documents_list.view_first_infocard
    doc_num1 = @mc.document_infocard.information.non_edit_number_element.attribute('value')
    int_doc_num1 = doc_num1.gsub(/\D/, '').to_i
    @mc.go_to.documents.view_documents
    @mc.documents_list.search.basic.title = second_infocard
    @mc.documents_list.search.search
    @mc.documents_list.view_first_infocard
    doc_num2 = @mc.document_infocard.information.non_edit_number_element.attribute('value')
    int_doc_num2 = doc_num2.gsub(/\D/, '').to_i
    return assert((int_doc_num1 + 1) == int_doc_num2)
  end

end
