INTERFACE zsd_sales_order_bo_ft_i
  PUBLIC .

  TYPES:
    BEGIN OF t_create_data,
      order_header_in  TYPE bapisdhd1,
      order_header_inx TYPE bapisdhd1x,
      order_items_in   TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY,
      order_items_inx  TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY,
      order_partners   TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY,
    END OF t_create_data .

  CLASS-METHODS create_by_data
    IMPORTING
      create_data              TYPE t_create_data
    RETURNING
      VALUE(rr_sales_order_bo) TYPE REF TO zsd_sales_order_bo_i.

  METHODS get_sales_order_bo
    IMPORTING
      !iv_sales_order_no TYPE vbak-vbeln
    RETURNING
      VALUE(rr_instance) TYPE REF TO zsd_sales_order_bo_i .
ENDINTERFACE.
