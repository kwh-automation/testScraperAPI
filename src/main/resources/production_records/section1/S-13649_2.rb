require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @title = uniq('Title_')
    @title_no_uniq = uniq('Title_', false)
    @id = uniq('VariantId_', false)
    @template_id = env['mbr_product_id']
    @template_name = env['mbr_product_name']
    @template = "#{@template_id} #{@template_name}"
    @phase = '1.1.1'
    @varying_properties = ['parameter']
    @new_parameter1 = 'This is a new phase step title'
    @new_parameter2 = 'Another parameter variation'

    pre_test
    test_user_can_view_variant_pdf
    test_pdf_contains_all_variations
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
    @mc.do.create_variant @title, @id, parent_template: @template
    @mc.variant_detail.create_variation @phase, '1', @varying_properties, new_parameter: @new_parameter1
    @mc.variant_detail.create_variation @phase, '2', @varying_properties, new_parameter: @new_parameter2
    @variant_id = @mc.url.split('/').last
    @mc.variant_detail.back
  end

  def test_user_can_view_variant_pdf
    @mc.variant_list.actions_view_pdf @id
    @downloaded_pdf = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf @downloaded_pdf
    assert @mc.pdf.find_text(@id), 'The pdf is not open, or does not contain the variant product id.'
  end

  def test_pdf_contains_all_variations
    assert @mc.pdf.find_text(@new_parameter1), 'The pdf does not contain the phase step title variation for 1.1.1.1'
    assert @mc.pdf.find_text(@new_parameter2), 'The pdf does not contain the phase step title variation for 1.1.1.2'
  end

  def clean_up
    @mc.pdf.close
    @mc.pdf.cleanup_downloads @downloaded_pdf

    sql_query_title = "DELETE FROM [mfg_cfg].[variation_phase_step_title] WHERE variant_id = '#{@variant_id}'"
    @mc.do.run_query(sql_query_title, print_query: true)

    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@title_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end

end