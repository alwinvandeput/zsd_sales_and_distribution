CLASS zsd_sales_order_bo_ft DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zsd_sales_order_bo_ft_i .

    CLASS-METHODS get_factory
      RETURNING VALUE(factory) TYPE REF TO zsd_sales_order_bo_ft_i.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS ZSD_SALES_ORDER_BO_FT IMPLEMENTATION.

  METHOD get_factory.

    factory = NEW zsd_sales_order_bo_ft( ).

  ENDMETHOD.

  METHOD zsd_sales_order_bo_ft_i~create_by_data.

    DATA:
      lt_return            TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY,
      lv_sales_document_no TYPE bapivbeln-vbeln.

    "The data must be changeable by the BAPI
    DATA(temp_create_data) = create_data.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in  = temp_create_data-order_header_in
        order_header_inx = temp_create_data-order_header_inx
        testrun          = ''
        convert          = ' '
      IMPORTING
        salesdocument    = lv_sales_document_no
      TABLES
        return           = lt_return
        order_items_in   = temp_create_data-order_items_in
        order_items_inx  = temp_create_data-order_items_inx
        order_partners   = temp_create_data-order_partners.

    "Error handling
*    DATA(lx_return) = NEW zcx_return3( ).
*    lx_return->add_bapiret2_table( lt_return ).
*    IF lx_return->has_messages( ) = abap_true.
*      RAISE EXCEPTION lx_return.
*    ENDIF.
    LOOP AT lt_return
      ASSIGNING FIELD-SYMBOL(<ls_return>).

      ASSERT <ls_return>-type CN 'AEX'.

    ENDLOOP.

    DATA(temp_sales_order_bo) = NEW zsd_sales_order_bo( ).

    temp_sales_order_bo->m_sales_order_no = lv_sales_document_no.

    rr_sales_order_bo = temp_sales_order_bo.

  ENDMETHOD.


  METHOD zsd_sales_order_bo_ft_i~get_sales_order_bo.

    DATA(lr_instance) = NEW zsd_sales_order_bo( ).

    lr_instance->m_sales_order_no = iv_sales_order_no.

    rr_instance = lr_instance.

  ENDMETHOD.

ENDCLASS.
