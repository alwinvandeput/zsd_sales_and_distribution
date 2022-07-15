INTERFACE zsd_sales_order_dp_ft_i
  PUBLIC .

  METHODS get_data_provider
    IMPORTING
      !sales_order_no       TYPE vbak-vbeln
    RETURNING
      VALUE(sales_order_dp) TYPE REF TO zsd_sales_order_dp_i .

ENDINTERFACE.
