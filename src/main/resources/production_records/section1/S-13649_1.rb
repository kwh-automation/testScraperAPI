require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @title_first = uniq('Title_') + '_AAA'
    @title_last = uniq('Title_') + '_ZZZ'
    @title_no_uniq = uniq('Title_', false)
    @id_first = uniq('VariantId_') + '_AAA'
    @id_last = uniq('VariantId_') + '_ZZZ'
    @template_id = env['mbr_product_id']
    @template_name = env['mbr_product_name']
    @template = "#{@template_id} #{@template_name}"
    @filter_string = 'Your search returned'

    pre_test
    test_user_can_start_creating_variants
    test_user_can_navigate_to_variants_list
    test_user_can_view_title_id_parent_and_revision_of_variant
    test_user_can_filter_variants
    test_user_can_sort_variants
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
  end

  def test_user_can_start_creating_variants
    @mc.ebr.variant_create
    assert @mc.variant_modal.save_element.visible?, 'The save button in the create variant modal is not visible.'
  end

  def test_user_can_navigate_to_variants_list
    create_variant @title_first, @id_first, @template
    @mc.do.create_variant @title_last, @id_last, parent_template: @template

    @mc.go_to.ebr
    @mc.ebr.variant_view_all
    assert @mc.variant_list.variant_title_header_element.visible?, 'The title header in the variant list is not visible.'
  end

  def test_user_can_view_title_id_parent_and_revision_of_variant
    assert (@mc.variant_list.variant_elements_exist? @title_first, @id_first, @template_name), 'The variant\'s title, id, parent template, and revision information are not visible.'
  end

  def test_user_can_filter_variants
    assert (@mc.variant_list.x_of_y_span_element.attribute('innerText').include? @filter_string), 'The list did not return filtered.'
  end

  def test_user_can_sort_variants
    @mc.variant_list.filter_by :variant_title, @title_no_uniq
    first_variant_id = @mc.variant_list.access_variant_list_data_by_coordinate 1, 2
    second_variant_id = @mc.variant_list.access_variant_list_data_by_coordinate 2, 2

    @mc.variant_list.product_id_header
    assert @mc.variant_list.access_variant_list_data_by_coordinate(1, 2) == second_variant_id, 'The variants did not swap.'
    assert @mc.variant_list.access_variant_list_data_by_coordinate(2, 2) == first_variant_id, 'The variants did not swap.'
  end

  def clean_up
    sql_query = "DELETE FROM [mfg_cfg].[variants] WHERE product_name like '%#{@title_no_uniq}%'"
    @mc.do.run_query(sql_query, print_query: true)
  end

  private
  def create_variant title, id, template, rev: 'A'
    @mc.variant_modal.product_name = title
    @mc.variant_modal.product_id = id
    @mc.variant_modal.baseline_mt_id = "#{template} (Rev: #{rev})"
    @mc.variant_modal.save
  end
end
