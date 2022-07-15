CLASS zsd_so_mass_update_prc DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED .

*  PUBLIC SECTION.
*
*    TYPES:
*      BEGIN OF gts_execute,
*        filter TYPE zzap_sd_sales_order_dp_i=>gts_filter,
*        change TYPE zzap_sd_sales_order_bo_i=>gts_change_req,
*      END OF gts_execute .
*    TYPES:
*      BEGIN OF gts_execute_result_item,
*        sales_order_no TYPE vbak-vbeln,
*        completed_ind  TYPE abap_bool,
*        return_list    TYPE bapiret2_t,
*      END OF gts_execute_result_item .
*    TYPES:
*      gtt_execute_result_list TYPE STANDARD TABLE OF gts_execute_result_item WITH DEFAULT KEY .
*    TYPES:
*      BEGIN OF gts_execute_result,
*        sales_order_no TYPE vbak-vbeln,
*      END OF gts_execute_result .
*
*    CLASS-METHODS get_instance
*      RETURNING
*        VALUE(rr_instance) TYPE REF TO zzap_sd_so_mass_update_prc .
*    CLASS-METHODS get_instance_for_test
*      IMPORTING
*        !ir_sales_order_dp    TYPE REF TO zzap_sd_sales_order_dp_i
*        !ir_sales_order_bo_ft TYPE REF TO zzap_sd_sales_order_bo_ft_i
*      RETURNING
*        VALUE(rr_instance)    TYPE REF TO zzap_sd_so_mass_update_prc .
*    METHODS execute
*      IMPORTING
*        !is_execute           TYPE gts_execute
*      RETURNING
*        VALUE(rt_result_list) TYPE gtt_execute_result_list .
*  PROTECTED SECTION.
*
*    DATA m_sales_order_dp TYPE REF TO zzap_sd_sales_order_dp_i .
*    DATA m_sales_order_bo_ft TYPE REF TO zzap_sd_sales_order_bo_ft_i .
*  PRIVATE SECTION.

*
*  METHOD execute.
*
*    DATA(lt_key_field_list) =
*      me->m_sales_order_dp->get_key_field_list(
*        is_execute-filter ).
*
*    DATA(ls_change) = is_execute-change.
*
*    LOOP AT lt_key_field_list
*      ASSIGNING FIELD-SYMBOL(<ls_key_field>).
*
*      APPEND INITIAL LINE TO rt_result_list
*        ASSIGNING FIELD-SYMBOL(<ls_result_item>).
*
*      <ls_result_item>-sales_order_no = <ls_key_field>-sales_order_no.
*
*      "Instantiate Sales order
*      DATA(lr_sales_order_bo) =
*        m_sales_order_bo_ft->get_instance_by_key(
*          iv_sales_order_no = <ls_key_field>-sales_order_no ).
*
*      "Change Sales order
*      data ls_change_2 type ZZAP_SD_SALES_ORDER_BO_I=>gts_change_req.
*      DATA(lt_return) = lr_sales_order_bo->change( ls_change_2 ).
*
*      "Remark: normally errors are handled the OO-exception way.
*      IF lt_return[] IS NOT INITIAL.
*        <ls_result_item>-return_list  = lt_return.
*        CONTINUE.
*      ENDIF.
*
*      IF is_execute-change-simulation = abap_false.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = abap_true
** IMPORTING
**           RETURN        =
*          .
*        "TODO: error handling
*
*      ELSE.
*        ROLLBACK WORK.
*      ENDIF.
*
*      <ls_result_item>-completed_ind = abap_true.
*
*    ENDLOOP.
*
*  ENDMETHOD.
*
*
*  METHOD get_instance.
*
*    rr_instance = NEW #( ).
*
*    rr_instance->m_sales_order_dp = NEW zzap_sd_sales_order_dp( ).
*
*    rr_instance->m_sales_order_bo_ft = NEW zzap_sd_sales_order_bo_ft( ).
*
*  ENDMETHOD.
*
*
*  METHOD get_instance_for_test.
*
*    rr_instance = NEW #( ).
*
*    rr_instance->m_sales_order_dp = ir_sales_order_dp.
*
*    rr_instance->m_sales_order_bo_ft = ir_sales_order_bo_ft.
*
*  ENDMETHOD.

ENDCLASS.

CLASS zsd_so_mass_update_prc implementation.
endclass.
