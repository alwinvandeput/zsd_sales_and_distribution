INTERFACE zsd_sales_order_bo_i
  PUBLIC .

  INTERFACES zbo_business_object_i.

  TYPES t_sales_order_no TYPE vbak-vbeln.
  TYPES gts_data_resp TYPE zsd_sales_order_dp_i=>t_bo_data.
  TYPES t_change_data TYPE zsd_sales_order_dao=>t_change_data.

  METHODS get_sales_order_no
    RETURNING
      VALUE(rv_sales_order_no) TYPE t_sales_order_no.

  METHODS get_data
    RETURNING
      VALUE(rs_data_resp) TYPE gts_data_resp .

  METHODS change
    IMPORTING change_data      TYPE t_change_data
    RETURNING VALUE(rt_return) TYPE bapiret2_t
    RAISING   zcx_return3.

  METHODS create_document
    IMPORTING form_name         TYPE fpname
              dialog_ind        TYPE abap_bool
              print_destination TYPE sfpoutputparams-dest
              language_code     TYPE nast-spras
              country_code      TYPE sfpdocparams-country OPTIONAL
    RETURNING VALUE(pdf_binary) TYPE xstring
    RAISING   zcx_return3.

  METHODS create_email
    IMPORTING form_name         TYPE fpname
              print_destination TYPE sfpoutputparams-dest
              language_code     TYPE nast-spras
              country_code      TYPE sfpdocparams-country OPTIONAL
    RAISING   zcx_return3.

ENDINTERFACE.
