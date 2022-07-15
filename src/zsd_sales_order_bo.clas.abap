CLASS zsd_sales_order_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zsd_sales_order_bo_ft .

  PUBLIC SECTION.

    INTERFACES zbo_business_object_i .
    INTERFACES zsd_sales_order_bo_i .
    INTERFACES zopm_outp_print_output_i.
    INTERFACES zopm_outp_external_send_i.

  PROTECTED SECTION.

    DATA m_sales_order_no TYPE vbak-vbeln .
    DATA m_dao TYPE REF TO zsd_sales_order_dao.

  PRIVATE SECTION.
ENDCLASS.

CLASS zsd_sales_order_bo IMPLEMENTATION.

  METHOD zsd_sales_order_bo_i~change.
    m_dao->change_data( change_data ).
  ENDMETHOD.


  METHOD zsd_sales_order_bo_i~get_data.
*    m_dao->get_data( ).
  ENDMETHOD.

  METHOD zbo_business_object_i~get_bo_key.
    bo_key = me->m_sales_order_no.
  ENDMETHOD.

  METHOD zsd_sales_order_bo_i~get_sales_order_no.
    rv_sales_order_no = me->m_sales_order_no.
  ENDMETHOD.

  METHOD zopm_outp_external_send_i~execute.

    me->zsd_sales_order_bo_i~create_email(
      form_name         = output_program-sform
      print_destination = output_message-ldest
      language_code     = output_message-spras ).

  ENDMETHOD.

  METHOD zsd_sales_order_bo_i~create_document.

    DATA data_provider TYPE REF TO zsd_sales_order_dp_i.
    data_provider = zsd_sales_order_dp_ft=>get_factory( )->get_data_provider(
      sales_order_no = me->m_sales_order_no ).
    DATA document_data TYPE zsd_sales_order_dp_i=>t_document_data.
    document_data = data_provider->get_document_data( language_code ).

    IF country_code IS NOT INITIAL.
      DATA(l_country_code) = country_code.
    ELSE.
      l_country_code = 'US'.  "Country code must be retrieved from sold-to party
    ENDIF.

    ASSERT language_code IS NOT INITIAL.
    ASSERT l_country_code IS NOT INITIAL.

    DATA adobe_document TYPE REF TO zadb_adobe_document.
    adobe_document =
      NEW zadb_adobe_document(
        VALUE #(
          form_name            = 'ZSD_SALES_ORDER'
          language_code        = language_code
          country_code         = l_country_code
          document_data_object = REF #( document_data  ) ) ).

    pdf_binary = adobe_document->get_pdf(
      dialog_ind        = dialog_ind
      print_destination = print_destination ).

  ENDMETHOD.

  METHOD zopm_outp_print_output_i~execute.

    zsd_sales_order_bo_i~create_document(
      dialog_ind        = dialog_ind
      form_name         = output_program-sform
      print_destination = output_message-ldest
      language_code     = output_message-spras ).

  ENDMETHOD.

  METHOD zsd_sales_order_bo_i~create_email.

    TRY.

        "-------------------------------------------------------------
        "Get PDF binary
        "-------------------------------------------------------------
        DATA(pdf_binary) = zsd_sales_order_bo_i~create_document(
          form_name         = form_name
          dialog_ind        = abap_false
          print_destination = print_destination
          language_code     = language_code
          country_code      = country_code ).

        "-------------------------------------------------------------
        "Get Email data
        "-------------------------------------------------------------
        DATA data_provider TYPE REF TO zsd_sales_order_dp_i.
        data_provider = zsd_sales_order_dp_ft=>get_factory(
          )->get_data_provider(
            sales_order_no = me->m_sales_order_no ).

        DATA(email_data) = data_provider->get_email_data( language_code ).

        "-------------------------------------------------------------
        "Get Email labels
        "-------------------------------------------------------------
        DATA(email_labels_data_obj) =
          ztxd_text_labels_obj_ft=>get_factory( )->get_text_labels_obj(
            text_name = 'ZSD_SALES_ORDER_EMAIL_LABELS'
              )->get_labels_data_obj(
                language_code   = language_code ).

        ASSIGN email_labels_data_obj->* TO FIELD-SYMBOL(<email_labels>).
        ASSIGN COMPONENT 'ORDER_NO' OF STRUCTURE <email_labels>
          TO FIELD-SYMBOL(<sales_order_label>).
        ASSERT sy-subrc = 0.

        "-------------------------------------------------------------
        "Set country code
        "-------------------------------------------------------------
        IF country_code IS NOT INITIAL.
          DATA(temp_country_code) = country_code.
        ELSE.
          temp_country_code = 'US'. "Must be retrieved from Sold to party
        ENDIF.

        "-------------------------------------------------------------
        "Set Email data
        "-------------------------------------------------------------
        DATA(ls_email_data) =
          VALUE zeml_extended_email_bo=>t_email(
            content_type            = zeml_extended_email_bo=>c_content_types-html

            layout_transform_type   = zeml_extended_email_bo=>c_layout_transform_types-xslt
            layout_transform_name   = 'ZSD_SALES_ORDER_HTML_EMAIL'
            email_data_obj          = REF #( email_data )
            labels_data_obj         = email_labels_data_obj

            country_key             = temp_country_code
            language_key            = language_code
            currency_key            = email_data-header-currency_key

            importance              = '5'
            sensitivity             = ''

            sender =
              VALUE #(
                name  = 'myCompany - noreply'
                email = 'noreply@mycompany.nl'
              )

            receivers =
              VALUE #(
                (
                  name  = email_data-sold_to_party-name
                  email = email_data-sold_to_party-email_address
                )
              )

            attachments = VALUE #(
              (
                attachment_type     = 'PDF'
                attachment_subject  = |{ <sales_order_label> } { email_data-header-order_no }.pdf|
                att_content_xstring = pdf_binary
              )
            )

          ).

        "-------------------------------------------------------------
        "Send Email
        "-------------------------------------------------------------
        DATA(lo_email_bo) =
          zeml_extended_email_bo_ft=>get_factory( )->create_email(
            ls_email_data ).

        lo_email_bo->send( ).

      CATCH zcx_return3 INTO DATA(return3_exc).

        RAISE EXCEPTION return3_exc.

      CATCH cx_root INTO DATA(root_exc).

        DATA(return_exc) = NEW zcx_return3( ).
        return_exc->add_exception_object( root_exc ).
        RAISE EXCEPTION return_exc.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
