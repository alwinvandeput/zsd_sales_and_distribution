CLASS td_sales_order_dp_ft DEFINITION DEFERRED.

CLASS td_sales_order_dp DEFINITION
  INHERITING FROM zsd_sales_order_dp
  FOR TESTING
  FRIENDS td_sales_order_dp_ft.

  PUBLIC SECTION.

    METHODS zsd_sales_order_dp_i~get_bo_data REDEFINITION.

ENDCLASS.

CLASS td_sales_order_dp IMPLEMENTATION.

  METHOD zsd_sales_order_dp_i~get_bo_data.

    bo_data = VALUE #(
      header = VALUE #(
        doc_number = '10000005'
        sold_to    = 12345
      )
      partners = VALUE #(
      )
    ).

    DO 50 TIMES.

      DATA(itm_number) = CONV vbap-posnr( sy-index * 10 ).

      APPEND
        VALUE #(
          itm_number  = itm_number
          material    = 'AABB001'
          short_text  = COND #(  WHEN language_code = 'N' THEN 'Fiets 1' ELSE 'Bicycle 1' )
          req_qty     = 4
          target_qu   = 'ST' )
        TO bo_data-items.

      APPEND
        VALUE #(
          itm_number = itm_number
          cond_st_no = '020' "Nett amount
          condvalue  = 1000 )
        TO bo_data-pricing_conditions.

      IF sy-index < 10.

        APPEND
          VALUE #(
            itm_number = itm_number
            cond_st_no = '850' "Tax amount
            cond_value = 6
            condvalue  = 1000 * '0.06' )
          TO bo_data-pricing_conditions.

        APPEND
          VALUE #(
            itm_number = itm_number
            cond_st_no = '900' "Gross amount
            condvalue  = 1060 )
          TO bo_data-pricing_conditions.

      ELSE.

        APPEND
          VALUE #(
            itm_number = itm_number
            cond_st_no = '850' "Tax amount
            cond_value = 19
            condvalue  = 1000 * '0.19' )
          TO bo_data-pricing_conditions.

        APPEND
          VALUE #(
            itm_number = itm_number
            cond_st_no = '900' "Gross amount
            condvalue  = 1190 )
          TO bo_data-pricing_conditions.

      ENDIF.

    ENDDO.

    bo_data-header_pricing = _calculate_header_pricing( bo_data-pricing_conditions ).

  ENDMETHOD.

ENDCLASS.


CLASS td_sales_order_dp_ft DEFINITION
  FOR TESTING.

  PUBLIC SECTION.

    INTERFACES zsd_sales_order_dp_ft_i.

ENDCLASS.

*class td_sales_order_dp definition local friends td_sales_order_dp_ft.

CLASS td_sales_order_dp_ft IMPLEMENTATION.

  METHOD zsd_sales_order_dp_ft_i~get_data_provider.

    DATA(temp_sales_order_dp) = NEW td_sales_order_dp(  ).

    temp_sales_order_dp->m_sales_order_no = sales_order_no.

    sales_order_dp = temp_sales_order_dp.

  ENDMETHOD.

ENDCLASS.

CLASS unit_test DEFINITION FOR TESTING
  DURATION LONG
  RISK LEVEL HARMLESS.

  "------------------------------------------------------
  "Prerequisites actions
  "- T:SO10 - Create Standard text ZSD_SALES_ORDER_DOCUMENT_LABELS in EN and NL
  "- T:SO10 - Create Standard text ZSD_SALES_ORDER_EMAIL_LABELS in EN and NL
  "------------------------------------------------------
  "ZSD_SALES_ORDER_DOCUMENT_LABELS ID ST language EN
*   order_number = Order number
*   item = Item
*   material = Material
*   description = Description
*   quantity = Quantity
*   unit = Unit
*   net_amount = Net amount
*   gross_amount = Gross amount

  "ZSD_SALES_ORDER_DOCUMENT_LABELS ID ST language NL
*   order_number = Ordernummer
*   item = Positie
*   material = Artikel
*   description = Beschrijving
*   quantity = Hoeveelheid
*   unit = Eenheid
*   net_amount = Netto bedrag
*   gross_amount = Bruto bedrag

  "ZSD_SALES_ORDER_EMAIL_LABELS ID ST language EN
**   sales_order = Sales order
**   order_no = Order number
**   body_text = Your sales order is attached to this email. For questions
*    please send us an email.

  "ZSD_SALES_ORDER_EMAIL_LABELS ID ST language NL
**   sales_order = Verkooporder
**   order_no = Ordernummer
**   body_text = Uw verkooporder is toegevoegd aan deze email. Voor vragen
*    graag een email naar ons verzenden.

  PRIVATE SECTION.

    "------------------------------------------------------
    "Unit tests based on Test Double data (=td_)
    "------------------------------------------------------
    METHODS td_create_document_en   ."FOR TESTING.  "Must be executed in SAP GUI
    METHODS td_create_document_nl   ."FOR TESTING.  "Must be executed in SAP GUI

    METHODS td_create_email_en      ."FOR TESTING.
    METHODS td_create_email_nl      ."FOR TESTING.

    "------------------------------------------------------
    "Unit tests based on real data
    "------------------------------------------------------
    METHODS get_document_data_en    ."FOR TESTING.
    METHODS get_document_data_nl    ."FOR TESTING.

    METHODS create_document_en      ."FOR TESTING.  "Must be executed in SAP GUI
    METHODS create_document_nl      ."FOR TESTING.  "Must be executed in SAP GUI

    METHODS create_email_en         ."FOR TESTING.

    "-----------------------------------------------------
    "TODO for upcoming blogs
    "-----------------------------------------------------
*    METHODS create_bo            ."FOR TESTING.
*
*    METHODS get_data             ."FOR TESTING.
*
*    METHODS change               ."FOR TESTING.

    METHODS _get_last_sales_order_no
      RETURNING VALUE(sales_order_no) TYPE zsd_sales_order_bo_i=>t_sales_order_no.

    METHODS _get_exp_sales_order_data
      IMPORTING sales_order_no            TYPE vbak-vbeln
      RETURNING VALUE(ls_exp_sales_order) TYPE zsd_sales_order_bo_i=>gts_data_resp.

    METHODS _assert_fail_return3
      IMPORTING return3_exc TYPE REF TO zcx_return3.

    METHODS _get_document_data
      IMPORTING language_code TYPE syst-langu.

    METHODS _create_document
      IMPORTING test_double_ind TYPE abap_bool DEFAULT abap_false
                language_code   TYPE syst-langu
                country_code    TYPE sfpdocparams-country.

    METHODS _create_email
      IMPORTING test_double_ind TYPE abap_bool DEFAULT abap_false
                language_code   TYPE syst-langu
                country_code    TYPE sfpdocparams-country.

ENDCLASS.       "unit_Test


CLASS unit_test IMPLEMENTATION.

*  METHOD create_bo.
*
*    DATA create_data TYPE zsd_sales_order_bo_ft_i=>t_create_data.
*
*    create_data = VALUE #(
*      order_header_in = VALUE #(
*        doc_type                       = 'TA'  "OF TA
*        sales_org                      = '1010'
*        distr_chan                     = '10'
*        division                       = '00'
*      )
*      order_items_in = VALUE #(
*        (
*          itm_number                     = '000010'
*          material                       = 'FG29'
*          target_qty                     = '1'
*          target_qu                      = 'ST'
*        )
*      )
*      order_partners = VALUE #(
*        (
*          partn_role                     = 'AG'
*          partn_numb                     = '0010100001'
*        )
*      )
*    ).
*
*
*    TRY.
*
*        DATA(sales_order_bo) =
*          zsd_sales_order_bo_ft=>get_factory( )->create_by_data( create_data ).
*
*        DATA(sales_order_no) = sales_order_bo->get_sales_order_no( ).
*
*        SET PARAMETER ID 'AUN' FIELD sales_order_no.
*
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = 'X'.
*
*      CATCH zcx_return3 INTO DATA(return3_exc).
*
*        _assert_fail_return3( return3_exc ).
*
*    ENDTRY.
*
*
*    "******************************************************************
*    "Assert
*    "******************************************************************
*
*    DATA(exp_sales_order_data) = _get_exp_sales_order_data( sales_order_no ).
*
*    sales_order_bo =
*      zsd_sales_order_bo_ft=>get_factory(
*        )->get_sales_order_bo(
*          sales_order_no ).
**
**    DATA(ls_act_sales_order) = lr_sales_order_bo->get_data( ).
***
**
**    "******************************************************************
**    "Clear fields not to be compared
**    "******************************************************************
**    CLEAR:
**      ls_act_sales_order-order_headers-rec_date,
**      ls_exp_sales_order-order_headers-rec_date,
**
**      ls_act_sales_order-order_headers-rec_time,
**      ls_exp_sales_order-order_headers-rec_time,
**
**      ls_act_sales_order-order_headers-conditions,
**      ls_exp_sales_order-order_headers-conditions.
**
**    LOOP AT ls_act_sales_order-order_items
**      ASSIGNING FIELD-SYMBOL(<ls_act_order_item>).
**      CLEAR:
**        <ls_act_order_item>-operation,
**        <ls_act_order_item>-doc_number,
**        <ls_act_order_item>-creat_date,
**        <ls_act_order_item>-created_by,
**        <ls_act_order_item>-rec_time,
**        <ls_act_order_item>-profit_seg.
**    ENDLOOP.
**
**    LOOP AT ls_exp_sales_order-order_items
**      ASSIGNING FIELD-SYMBOL(<ls_exp_order_item>).
**      CLEAR:
**        <ls_exp_order_item>-operation,
**        <ls_exp_order_item>-doc_number,
**        <ls_exp_order_item>-creat_date,
**        <ls_exp_order_item>-created_by,
**        <ls_exp_order_item>-rec_time,
**        <ls_exp_order_item>-profit_seg.
**    ENDLOOP.
**
**    LOOP AT ls_act_sales_order-order_partners
**      ASSIGNING FIELD-SYMBOL(<ls_act_partner>).
**      CLEAR:
**        <ls_act_partner>-sd_doc.
**    ENDLOOP.
**
**    LOOP AT ls_exp_sales_order-order_partners
**      ASSIGNING FIELD-SYMBOL(<ls_exp_partner>).
**      CLEAR:
**        <ls_exp_partner>-sd_doc.
**    ENDLOOP.
**
**    "******************************************************************
**    "Assert
**    "******************************************************************
**
**    zcl_abap_unit_assert=>assert_equals(
**      act   = ls_act_sales_order
**      exp   = ls_exp_sales_order
**      msg   = 'Sales order create is not equal' ).
**
**  ENDMETHOD.
*
*
*  ENDMETHOD.

*  METHOD get_data.
*
*  ENDMETHOD.

*  METHOD change.
*
*  ENDMETHOD.

  METHOD _get_exp_sales_order_data.

    ls_exp_sales_order = VALUE #(
      header = VALUE #(
        operation                      = '005'
        doc_number                     = sales_order_no
*        rec_date                       = '20200524'
*        rec_time                       = '184615'
        created_by                     = sy-uname
        doc_date                       = sy-datum
        sd_doc_cat                     = 'C'
        tran_group                     = '0'
        doc_type                       = 'TA'
        currency                       = 'EUR'
        curren_iso                     = 'EUR'
        sales_org                      = '1010'
        distr_chan                     = '10'
        division                       = '00'
*        conditions                     = '0000003213'
        req_date_h                     = sy-datum
        date_type                      = '1'
        sd_pric_pr                     = 'Y10101'
        ship_cond                      = '01'
        ordbilltyp                     = 'F2'
        ord_probab                     = '100'
        telephone                      = '09990 4513-0'
        sold_to                        = '0010100001'
        stat_curr                      = 'EUR'
        isostatcur                     = 'EUR'
        co_area                        = 'A000'
        c_ctr_area                     = '1000'
        curr_cred                      = 'USD'
        isocurrcre                     = 'USD'
        comp_code                      = '1010'
        kalsm_ch                       = 'YB0001'
        sd_doc_cat_long                = 'C'
      )
      items = VALUE #(
        (
*          operation                      = '005'
*          doc_number                     = '0000000003'
          itm_number                     = '000010'
          material                       = 'FG29'
          mat_entrd                      = 'FG29'
          matl_group                     = 'L004'
          short_text                     = 'FIN29, MTS-PI, PD, Charge-Verfalldatum'
          item_categ                     = 'TAN'
          rel_for_bi                     = 'A'
          target_qty                     = '1.000'
          target_qu                      = 'ST'
          t_unit_iso                     = 'PCE'
          targ_qty_n                     = '1'
          targ_qty_d                     = '1'
          base_uom                       = 'BOT'
          t_bas_unit                     = 'BO'
          division                       = '00'
          currency                       = 'EUR'
          curren_iso                     = 'EUR'
          sales_unit                     = 'BOT'
          isocodunit                     = 'BO'
          sales_qty1                     = '1'
          sales_qty2                     = '1'
          unit_of_wt                     = 'KG'
          unit_wtiso                     = 'KGM'
          plant                          = '1010'
          ship_point                     = '1010'
          route                          = 'TR0001'
          order_prob                     = '100'
*          creat_date                     = '20200524'
*          created_by                     = 'AVANDEPUT'
*          rec_time                       = '184618'
          tax_class1                     = '1'
          cond_p_unt                     = '1'
          cond_unit                      = 'BOT'
          conisounit                     = 'BO'
          availcheck                     = 'SR'
          acct_assgt                     = '03'
          price_ok                       = 'X'
          batch_mgmt                     = 'X'
          ind_btch                       = 'X'
          exch_rate                      = '1.00000'
          ean_upc                        = '4012345900101'
          profit_ctr                     = 'YB110'
          alloc_indi                     = '1'
*          profit_seg                     = '0000000203'
          reqmtstyp                      = 'KSV'
          actcredid                      = 'X'
          cr_exchrat                     = '0.92081'
          mrp_area                       = '1010'
          cr_exchrat_v                   = '1.08600'
          log_system_own                 = 'S4ACLNT401'
          material_long                  = 'FG29'
          mat_entrd_long                 = 'FG29'
        )
      )
*      order_partners = VALUE #(
*        (
*          operation                      = '005'
**          sd_doc                         = '0000000003'
*          partn_role                     = 'AG'
*          customer                       = '0010100001'
*          address                        = '0000023475'
*          country                        = 'DE'
*          countryiso                     = 'DE'
*          addre_indi                     = 'D'
*          transpzone                     = '0000000002'
*        )
*        (
*          operation                      = '005'
**          sd_doc                         = '0000000003'
*          partn_role                     = 'RE'
*          customer                       = '0010100001'
*          address                        = '0000023475'
*          country                        = 'DE'
*          countryiso                     = 'DE'
*          addre_indi                     = 'D'
*          transpzone                     = '0000000002'
*        )
*        (
*          operation                      = '005'
**          sd_doc                         = '0000000003'
*          partn_role                     = 'RG'
*          customer                       = '0010100001'
*          address                        = '0000023475'
*          country                        = 'DE'
*          countryiso                     = 'DE'
*          addre_indi                     = 'D'
*          transpzone                     = '0000000002'
*        )
*        (
*          operation                      = '005'
**          sd_doc                         = '0000000003'
*          partn_role                     = 'WE'
*          customer                       = '0010100001'
*          address                        = '0000023475'
*          country                        = 'DE'
*          countryiso                     = 'DE'
*          addre_indi                     = 'D'
*          transpzone                     = '0000000002'
*        )
*      )
    ).

  ENDMETHOD.

  METHOD _get_last_sales_order_no.

    SELECT vbeln
      FROM vbak
      ORDER BY
        erdat DESCENDING,
        erzet DESCENDING,
        vbeln DESCENDING
      INTO TABLE @DATA(sales_orders)
      UP TO 1 ROWS.

    cl_abap_unit_assert=>assert_subrc(
      exp = 0
      act = sy-subrc ).

    sales_order_no = sales_orders[ 1 ].

  ENDMETHOD.

  METHOD _assert_fail_return3.

    DATA(return) = return3_exc->get_bapiret2_struc( ).

    cl_abap_unit_assert=>fail(
      msg    = |ZCX_RETURN3 error. ID: { return-id }, No. { return-number }|
      detail = return3_exc->get_text( ) ).

  ENDMETHOD.

  METHOD get_document_data_en.

    _get_document_data(
      language_code = 'E' ).

  ENDMETHOD.

  METHOD get_document_data_nl.

    _get_document_data(
      language_code = 'N' ).

  ENDMETHOD.

  METHOD _get_document_data.

    TRY.

        DATA(sales_order_no) = me->_get_last_sales_order_no( ).

        DATA(data_provider) = zsd_sales_order_dp_ft=>get_factory( )->get_data_provider( sales_order_no ).

        DATA(document_data) = data_provider->get_document_data( language_code = language_code ).

        "Now check the data in the debugger (or compare it in an ASSERT_EQUALS( ))
        BREAK-POINT.

      CATCH zcx_return3 INTO DATA(return3_exc).

        _assert_fail_return3( return3_exc ).

    ENDTRY.

  ENDMETHOD.

  METHOD td_create_document_en.

    _create_document(
      test_double_ind = abap_true
      language_code   = 'E'
      country_code    = 'US' ).

  ENDMETHOD.

  METHOD td_create_document_nl.

    _create_document(
      test_double_ind = abap_true
      language_code   = 'N'
      country_code    = 'NL' ).

  ENDMETHOD.

  METHOD create_document_en.

    _create_document(
      language_code = 'E'
      country_code   = 'US' ).

  ENDMETHOD.

  METHOD create_document_nl.

    _create_document(
      language_code = 'N'
      country_code  = 'NL' ).

  ENDMETHOD.

  METHOD _create_document.

    TRY.

        IF test_double_ind = abap_false.

          DATA(sales_order_no) = me->_get_last_sales_order_no( ).

        ELSE.

          sales_order_no = '10000005'.

          DATA(td_sales_order_dp_ft) = NEW td_sales_order_dp_ft( ).
          zsd_sales_order_dp_ft=>set_factory( td_sales_order_dp_ft ).

        ENDIF.

        DATA(sales_order_bo) =
          zsd_sales_order_bo_ft=>get_factory(
            )->get_sales_order_bo(
              sales_order_no ).

        sales_order_bo->create_document(
          form_name         = 'ZSD_SALES_ORDER'
          dialog_ind        = abap_true
          print_destination = 'LP01'
          language_code     = language_code
          country_code      = country_code ).

      CATCH zcx_return3 INTO DATA(return3_exc).

        _assert_fail_return3( return3_exc ).

    ENDTRY.

  ENDMETHOD.

  METHOD td_create_email_en.

    _create_email(
      test_double_ind = abap_true
      language_code = 'E'
      country_code   = 'US' ).

  ENDMETHOD.

  METHOD td_create_email_nl.

    _create_email(
      test_double_ind = abap_true
      language_code = 'N'
      country_code   = 'NL' ).

  ENDMETHOD.

  METHOD create_email_en.

    _create_email(
      test_double_ind = abap_false
      language_code = 'E'
      country_code   = 'US' ).

  ENDMETHOD.

  METHOD _create_email.

    TRY.

        IF test_double_ind = abap_false.

          DATA(sales_order_no) = me->_get_last_sales_order_no( ).

        ELSE.

          sales_order_no = '10000005'.

          DATA(td_sales_order_dp_ft) = NEW td_sales_order_dp_ft( ).
          zsd_sales_order_dp_ft=>set_factory( td_sales_order_dp_ft ).

        ENDIF.

        DATA(sales_order_bo) =
          zsd_sales_order_bo_ft=>get_factory(
            )->get_sales_order_bo(
              sales_order_no ).

        sales_order_bo->create_email(
          form_name         = 'ZSD_SALES_ORDER'
          print_destination = 'LP01'
          language_code     = language_code
          country_code      = country_code ).

      CATCH zcx_return3 INTO DATA(return3_exc).

        _assert_fail_return3( return3_exc ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
