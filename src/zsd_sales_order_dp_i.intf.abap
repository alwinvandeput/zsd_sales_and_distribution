INTERFACE zsd_sales_order_dp_i
  PUBLIC .

  "---------------------------------------------------
  "Sales order
  "---------------------------------------------------
  TYPES:
    t_amount TYPE p LENGTH 16 DECIMALS 2.

  TYPES:
    BEGIN OF t_bo_tax,
      percentage TYPE bapisdcond-cond_value,
      amount     TYPE t_amount,
    END OF t_bo_tax,
    BEGIN OF t_bo_header_pricing,
      net_amount   TYPE t_amount,
      gross_amount TYPE t_amount,
      taxes        TYPE STANDARD TABLE OF t_bo_tax WITH EMPTY KEY,
    END OF t_bo_header_pricing,
    BEGIN OF t_bo_data,
      header             TYPE bapisdhd,
      items              TYPE STANDARD TABLE OF bapisdit WITH DEFAULT KEY,
      partners           TYPE STANDARD TABLE OF bapisdpart  WITH DEFAULT KEY,
      pricing_conditions TYPE STANDARD TABLE OF bapisdcond WITH DEFAULT KEY,
      header_pricing     TYPE t_bo_header_pricing,
    END OF t_bo_data.

  "---------------------------------------------------
  "Document
  "---------------------------------------------------
  TYPES:
    BEGIN OF t_doc_header_data,
      doc_number TYPE string,
    END  OF t_doc_header_data,

    BEGIN OF t_doc_item_data,
      doc_number TYPE string,
      itm_number TYPE string,
      material   TYPE string,
      short_text TYPE bapisdit-short_text,
      quantity   TYPE bapisdit-req_qty,
      unit       TYPE bapisdit-target_qu,
      net_amount TYPE t_amount,
    END OF t_doc_item_data,

    BEGIN OF t_document_labels,
      order_number TYPE string,
      item         TYPE string,
      material     TYPE string,
      description  TYPE string,
      quantity     TYPE string,
      unit         TYPE string,
      net_amount   TYPE string,
      gross_amount TYPE string,
    END OF t_document_labels,

    BEGIN OF t_document_data,
      header         TYPE t_doc_header_data,
      items          TYPE STANDARD TABLE OF t_doc_item_data WITH DEFAULT KEY,
      header_pricing TYPE t_bo_header_pricing,
      labels         TYPE t_document_labels,
    END OF t_document_data.

  "---------------------------------------------------
  "Email
  "---------------------------------------------------
  TYPES:
    BEGIN OF t_email_header_data,
      order_no     TYPE vbak-vbeln,
      nett_amount  TYPE vbak-netwr,
      currency_key TYPE vbak-waerk,
      country_key  TYPE t005x-land,
    END  OF t_email_header_data,
    BEGIN OF t_email_item,
      item_no     TYPE string,
      description TYPE makt-maktx,
      quantity    TYPE vbap-zmeng,
      unit        TYPE c length 5,
      nett_amount TYPE vbap-netwr,
    END OF t_email_item,
    BEGIN OF t_email_sold_to_party,
      customer_no   TYPE bapisdpart-customer,
      address_no    TYPE bapisdpart-address,
      name          TYPE string,
      language_code TYPE syst-langu,
      email_address TYPE string,
    END OF t_email_sold_to_party,
    BEGIN OF t_email_data,
      header        TYPE t_email_header_data,
      sold_to_party TYPE t_email_sold_to_party,
      items         TYPE STANDARD TABLE OF t_email_item WITH DEFAULT KEY,
    END OF t_email_data.

  "---------------------------------------------------
  "Methods
  "---------------------------------------------------
  METHODS get_bo_data
    IMPORTING language_code  TYPE syst-langu
    RETURNING VALUE(bo_data) TYPE t_bo_data
    RAISING   zcx_return3.

  METHODS get_document_data
    IMPORTING language_code        TYPE syst-langu
    RETURNING VALUE(document_data) TYPE t_document_data
    RAISING   zcx_return3.

  METHODS get_email_data
    IMPORTING language_code     TYPE syst-langu
    RETURNING VALUE(email_data) TYPE t_email_data
    RAISING   zcx_return3.

ENDINTERFACE.
