*CLASS ltd_sd_sales_order_dp DEFINITION FOR TESTING.
*
*  PUBLIC SECTION.
*    INTERFACES zzap_sd_sales_order_dp_i.
*
*    DATA m_filter TYPE zzap_sd_sales_order_dp_i=>gts_filter.
*
*ENDCLASS.
*
*CLASS ltd_sd_sales_order_dp IMPLEMENTATION.
*
*  METHOD zzap_sd_sales_order_dp_i~get_key_field_list.
*
*    m_filter = is_filter.
*
*    rt_list = VALUE #(
*      ( sales_order_no = '12345678' )
*    ).
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS ltd_sd_sales_order_bo DEFINITION FOR TESTING.
*
*  PUBLIC SECTION.
*    INTERFACES zzap_sd_sales_order_bo_i PARTIALLY IMPLEMENTED.
*
*    DATA gv_sales_order_no TYPE vbak-vbeln.
*    DATA gs_change TYPE zzap_sd_sales_order_bo_i=>gts_change_req.
*
*ENDCLASS.
*
*CLASS ltd_sd_sales_order_bo IMPLEMENTATION.
*
*  METHOD zzap_sd_sales_order_bo_i~change.
*    gs_change = is_change_req.
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS ltd_sd_sales_order_bo_ft DEFINITION FOR TESTING.
*
*  PUBLIC SECTION.
*    INTERFACES zzap_sd_sales_order_bo_ft_i.
*
*    DATA gt_instances TYPE STANDARD TABLE OF REF TO ltd_sd_sales_order_bo.
*
*ENDCLASS.
*
*CLASS ltd_sd_sales_order_bo_ft IMPLEMENTATION.
*
*  METHOD zzap_sd_sales_order_bo_ft_i~get_instance_by_key.
*
*    DATA(lr_instance) = NEW ltd_sd_sales_order_bo( ).
*
*    lr_instance->gv_sales_order_no = iv_sales_order_no.
*
*    rr_instance = lr_instance.
*
*    APPEND lr_instance TO gt_instances.
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS ltc_execute DEFINITION FOR TESTING
*  DURATION SHORT
*  RISK LEVEL HARMLESS.
*
*  PRIVATE SECTION.
*    METHODS no_test_double     ."FOR TESTING.
*    METHODS with_test_double   FOR TESTING.
*ENDCLASS.       "unit_Test
*
*
*CLASS ltc_execute IMPLEMENTATION.
*
*  METHOD no_test_double.
*
*    "Given
*    DATA(lr_cut) = zzap_sd_so_mass_update_prc=>get_instance( ).
*
*    "When
*    DATA(ls_execute) =
*      VALUE zzap_sd_so_mass_update_prc=>gts_execute(
*        filter = VALUE #(
*          sales_order_no_rng = VALUE #(
*            (
*              sign   = 'I'
*              option = 'EQ'
*              low    = '0000000003'
*
*            )
*          )
*        )
*        change = VALUE #(
*          order_header_in = VALUE #(
*            purch_no_c       = CONV #( |Test { sy-datum } { sy-uzeit } | )
*           )
*          order_header_inx = VALUE #(
*            updateflag       = 'U'
*            purch_no_c       = abap_true )
*          simulation       = abap_false
*        )
*      ).
*
*    DATA(lt_act_list) = lr_cut->execute( ls_execute ).
*
*    "Then
*    DATA(lt_exp_list) = VALUE zzap_sd_so_mass_update_prc=>gtt_execute_result_list(
*      (
*        sales_order_no = '0000000003'
*        completed_ind  = abap_true
*        return_list    = VALUE #( )
*      )
*    ).
*
*    "Check result list
*    cl_abap_unit_assert=>assert_equals(
*        act                  = lt_act_list
*        exp                  = lt_exp_list ).
*
*    "Check Sales order
*    "- Remark! This can be done over here, however it should be done by the unit test of Sales Oder BO
*    LOOP AT lt_act_list
*      ASSIGNING FIELD-SYMBOL(<ls_sales_order>).
*
*      DATA(lr_sales_order_bo) =
*        NEW zzap_sd_sales_order_bo_ft( )->zzap_sd_sales_order_bo_ft_i~get_instance_by_key(
*          <ls_sales_order>-sales_order_no ).
*
*      DATA(ls_act_so_data) = lr_sales_order_bo->get_data( ).
*
*      "Assert the data
*      cl_abap_unit_assert=>assert_equals(
*          act                  = ls_act_so_data-header-purch_no
*          exp                  = ls_execute-change-order_header_in-purch_no_c ).
*
*    ENDLOOP.
*
*  ENDMETHOD.
*
*  METHOD with_test_double.
*
*    "Test doubles
*    DATA(lr_sales_order_dp_td) = NEW ltd_sd_sales_order_dp( ).
*
*    DATA(lr_sales_order_bo_ft_td) = NEW ltd_sd_sales_order_bo_ft( ).
*
*    "Given
*    DATA(lr_cut) = zzap_sd_so_mass_update_prc=>get_instance_for_test(
*      ir_sales_order_dp         = lr_sales_order_dp_td
*      ir_sales_order_bo_ft      = lr_sales_order_bo_ft_td
*    ).
*
*    "When
*    DATA(ls_execute) = VALUE zzap_sd_so_mass_update_prc=>gts_execute(
*      filter = VALUE #(
*        sales_order_no_rng = VALUE #(
*          (
*            sign   = 'I'
*            option = 'EQ'
*            low    = '12345678'
*
*          )
*        )
*      )
*      change = VALUE #(
*        order_header_in  = VALUE #(
*          distr_chan = '10' )
*        order_header_inx = VALUE #(
*          distr_chan = abap_true )
*        simulation       = abap_true
*
*      )
*    ).
*
*    DATA(lt_act_list) = lr_cut->execute(
*      is_execute = ls_execute ).
*
*    "Then
*
*    "- Check Test double: Data provider
*    cl_abap_unit_assert=>assert_equals(
*        act                  = lr_sales_order_dp_td->m_filter
*        exp                  = ls_execute-filter ).
*
*    "- Check Test double: Factory
*    DATA(lr_temp_so_bo) = lr_sales_order_bo_ft_td->gt_instances[ 1 ].
*
*    cl_abap_unit_assert=>assert_equals(
*        act                  = lr_temp_so_bo->gv_sales_order_no
*        exp                  = '12345678' ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act                  = lr_temp_so_bo->gs_change
*        exp                  = ls_execute-change ).
*
*    "- Check result of Mass update Execute method
*    DATA(lt_exp_list) = VALUE zzap_sd_so_mass_update_prc=>gtt_execute_result_list(
*      (
*        sales_order_no = '12345678'
*        completed_ind  = abap_true
*      )
*    ).
*
*    cl_abap_unit_assert=>assert_equals(
*        act                  = lt_act_list
*        exp                  = lt_exp_list ).
*
*  ENDMETHOD.
*
*ENDCLASS.
