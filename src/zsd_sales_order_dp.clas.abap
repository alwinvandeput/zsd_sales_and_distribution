CLASS zsd_sales_order_dp DEFINITION
  PUBLIC
  CREATE PROTECTED
  GLOBAL FRIENDS zsd_sales_order_dp_ft.

  PUBLIC SECTION.

    INTERFACES zsd_sales_order_dp_i .

  PROTECTED SECTION.

    METHODS _calculate_header_pricing
      IMPORTING pricing_conditions    TYPE zsd_sales_order_dp_i~t_bo_data-pricing_conditions
      RETURNING VALUE(header_pricing) TYPE zsd_sales_order_dp_i~t_bo_header_pricing.

    DATA m_sales_order_no TYPE vbak-vbeln.

  PRIVATE SECTION.

    DATA m_buffer_bo_data TYPE zsd_sales_order_dp_i~t_bo_data.

ENDCLASS.

CLASS zsd_sales_order_dp IMPLEMENTATION.

  METHOD zsd_sales_order_dp_i~get_bo_data.

    IF m_buffer_bo_data IS NOT INITIAL.
      bo_data = m_buffer_bo_data.
      RETURN.
    ENDIF.

    DATA(bapi_view) =
      VALUE order_view(
        header        = abap_true
        item          = abap_true
        sdcond        = abap_true ).

    DATA sales_documents TYPE STANDARD TABLE OF sales_key WITH DEFAULT KEY.

    sales_documents =
      VALUE #(
        ( vbeln = me->m_sales_order_no ) ).

    "-----------------------------------------------------------
    "Call function
    "-----------------------------------------------------------
    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_INIT'.
    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_SWITCH'
      EXPORTING
        need_lang = language_code.

    DATA temp_headers TYPE STANDARD TABLE OF bapisdhd WITH DEFAULT KEY.
    CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
      EXPORTING
        i_bapi_view          = bapi_view
      TABLES
        sales_documents      = sales_documents
        order_headers_out    = temp_headers
        order_items_out      = bo_data-items
        order_partners_out   = bo_data-partners
        order_conditions_out = bo_data-pricing_conditions.

    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_FINISH'.

    "-----------------------------------------------------------
    "Handle errors
    "-----------------------------------------------------------
    IF temp_headers[] IS INITIAL.
      "Sales order &1 does not exist
      RAISE EXCEPTION TYPE zcx_return3
        MESSAGE e003
          WITH me->m_sales_order_no.
    ENDIF.

    bo_data-header = temp_headers[ 1 ].

    "-----------------------------------------------------------
    "Calculate data
    "-----------------------------------------------------------
    bo_data-header_pricing = _calculate_header_pricing( bo_data-pricing_conditions ).

  ENDMETHOD.

  METHOD _calculate_header_pricing.

    "- Header pricing
    LOOP AT pricing_conditions
      ASSIGNING FIELD-SYMBOL(<pricing_condition>).

      CASE <pricing_condition>-cond_st_no.

        WHEN '020'. "Nett amount

          header_pricing-net_amount =
            header_pricing-net_amount + <pricing_condition>-condvalue.

        WHEN '900'. "Gross amount

          header_pricing-gross_amount =
            header_pricing-gross_amount + <pricing_condition>-condvalue.

        WHEN '850'. "Tax amount

          READ TABLE header_pricing-taxes
            WITH KEY percentage = <pricing_condition>-cond_value
            ASSIGNING FIELD-SYMBOL(<tax>).

          IF sy-subrc <> 0.

            APPEND INITIAL LINE TO header_pricing-taxes
              ASSIGNING <tax>.

            <tax>-percentage = <pricing_condition>-cond_value.
            <tax>-amount     = <pricing_condition>-condvalue.

          ELSE.

            <tax>-amount =
              <tax>-amount + <pricing_condition>-condvalue.

          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD zsd_sales_order_dp_i~get_document_data.

    "Function 'BAPISDORDER_GETDETAILEDLIST' is used to read the data.
    "When it is too slow, query's can be used instead to read only the needed fields.
    DATA(bo_data) = me->zsd_sales_order_dp_i~get_bo_data( language_code ).

    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_INIT'.
    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_SWITCH'
      EXPORTING
        need_lang = language_code.

    document_data-header = VALUE #(
      doc_number = |{ bo_data-header-doc_number ALPHA = OUT }|
    ).

    document_data-header_pricing = CORRESPONDING #( bo_data-header_pricing ).

    "---------------------------------------------------
    "Items
    "---------------------------------------------------
    LOOP AT bo_data-items
      ASSIGNING FIELD-SYMBOL(<bo_item>).

      APPEND INITIAL LINE TO document_data-items
        ASSIGNING FIELD-SYMBOL(<document_item>).

      <document_item> = VALUE #(
        itm_number = |{ <bo_item>-itm_number ALPHA = OUT }|
        material   = <bo_item>-material
        short_text = <bo_item>-short_text
        quantity   = <bo_item>-req_qty
      ).

      WRITE <bo_item>-target_qu TO <document_item>-unit.

    ENDLOOP.

    LOOP AT document_data-items
      ASSIGNING FIELD-SYMBOL(<item>).

      LOOP AT bo_data-pricing_conditions
        ASSIGNING FIELD-SYMBOL(<pricing_condition>)
        WHERE itm_number = <item>-itm_number.

        CASE <pricing_condition>-cond_st_no.

          WHEN '020'. "Nett amount

            <item>-net_amount = <pricing_condition>-condvalue.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_FINISH'.

    "-------------------------------------------------------
    "Get labels
    "-------------------------------------------------------
    ztxd_text_labels_obj_ft=>get_factory( )->get_text_labels_obj(
      text_name = 'ZSD_SALES_ORDER_DOCUMENT_LABELS'
        )->get_labels_static_struct(
          EXPORTING language_code    = language_code
          CHANGING  cs_labels_struct = document_data-labels ).

  ENDMETHOD.

  METHOD zsd_sales_order_dp_i~get_email_data.

    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_INIT'.
    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_SWITCH'
      EXPORTING
        need_lang = language_code.

    "Function 'BAPISDORDER_GETDETAILEDLIST' is used to read the data.
    "When it is too slow, query's can be used instead to read only the needed fields.
    DATA(bo_data) = me->zsd_sales_order_dp_i~get_bo_data( language_code ).

    email_data-header = VALUE #(
      order_no     = |{ bo_data-header-doc_number ALPHA = OUT }|
      nett_amount  = bo_data-header_pricing-net_amount
      currency_key = bo_data-header-currency
      country_key  = 'US' "Must be retrieved from sold to party
    ).

    email_data-sold_to_party = VALUE #(
      customer_no  = bo_data-header-sold_to

      "Must be read from table ADRC
      name = 'Alwin van de Put'

      "Must be read from table field ADRC-LANGU
      language_code = 'E'

      "Must be read from table ADR6
      email_address = 'alwin.vandeput@mycompany.nl'
    ).

    LOOP AT bo_data-items
       ASSIGNING FIELD-SYMBOL(<bo_item>).

      APPEND INITIAL LINE TO email_data-items
        ASSIGNING FIELD-SYMBOL(<email_item>).

      <email_item> = VALUE #(
        item_no     = |{ <bo_item>-itm_number ALPHA = OUT }|
        description = <bo_item>-short_text
        quantity    = <bo_item>-req_qty
      ).

      WRITE <bo_item>-target_qu TO <email_item>-unit.

    ENDLOOP.

    LOOP AT email_data-items
      ASSIGNING FIELD-SYMBOL(<item>).

      LOOP AT bo_data-pricing_conditions
        ASSIGNING FIELD-SYMBOL(<pricing_condition>)
        WHERE itm_number = <item>-item_no.

        CASE <pricing_condition>-cond_st_no.

          WHEN '020'. "Nett amount

            <item>-nett_amount = <pricing_condition>-condvalue.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

"TODO: future change is to read labels in the data provider,
"just like reading data for documents: zsd_sales_order_dp_i~get_document_data
*    "-------------------------------------------------------
*    "Get labels
*    "-------------------------------------------------------
*    ztxd_text_labels_obj_ft=>get_factory( )->get_text_labels_obj(
*      text_name = 'ZSD_SALES_ORDER_EMAIL_LABELS'
*        )->get_labels_static_struct(
*          EXPORTING language_code    = language_code
*          CHANGING  cs_labels_struct = document_data-labels ).

    CALL FUNCTION 'SCP_MIXED_LANGUAGES_1_FINISH'.

  ENDMETHOD.

ENDCLASS.
