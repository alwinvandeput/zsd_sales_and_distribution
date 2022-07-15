CLASS zsd_sales_order_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES t_sales_order_no TYPE vbak-vbeln.

    TYPES:
      BEGIN OF t_change_data,
        order_header_in  TYPE bapisdhead1,
        order_header_inx TYPE bapisdhead1x,
        simulation       TYPE bapiflag-bapiflag,
      END OF t_change_data.

    CLASS-METHODS create_dao
      RETURNING VALUE(dao) TYPE REF TO zsd_sales_order_dao.

    CLASS-METHODS get_dao
      IMPORTING sales_order_no TYPE t_sales_order_no
      RETURNING VALUE(dao)     TYPE REF TO zsd_sales_order_dao.

*    METHODS get_data
*      returning value(bo_data) type t_bo_data
*      RAISING   zcx_return3.

    METHODS change_data
      IMPORTING change_data TYPE t_change_data
      RAISING   zcx_return3.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA m_sales_order_no TYPE t_sales_order_no.

ENDCLASS.

CLASS zsd_sales_order_dao IMPLEMENTATION.

  METHOD create_dao.

    "TODO

  ENDMETHOD.

  METHOD get_dao.

    "TODO

  ENDMETHOD.

  METHOD change_data.

    DATA return_tab TYPE bapiret2_t.

    DATA(temp_change_data) = change_data.

    "TODO: add items
    CALL FUNCTION 'BAPI_SALESDOCUMENT_CHANGE'
      EXPORTING
        salesdocument    = m_sales_order_no
        order_header_in  = temp_change_data-order_header_in
        order_header_inx = temp_change_data-order_header_inx
        simulation       = temp_change_data-simulation
      TABLES
        return           = return_tab
*       ITEM_IN          = temp_change_data-item_in
*       ITEM_INX         = temp_change_data-item_inx
      .

    DATA(return3_exc) = NEW zcx_return3( ).
    return3_exc->add_bapiret2_table( return_tab ).
    IF return3_exc->has_messages( ) = abap_true.
      RAISE EXCEPTION return3_exc.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
