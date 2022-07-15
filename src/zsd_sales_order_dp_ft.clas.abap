CLASS zsd_sales_order_dp_ft DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zsd_sales_order_dp_ft_i .

    CLASS-METHODS get_factory
      RETURNING VALUE(factory) TYPE REF TO zsd_sales_order_dp_ft_i.

    CLASS-METHODS set_factory
      IMPORTING factory TYPE REF TO zsd_sales_order_dp_ft_i.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA m_factory TYPE REF TO zsd_sales_order_dp_ft_i.

ENDCLASS.

CLASS zsd_sales_order_dp_ft IMPLEMENTATION.

  METHOD get_factory.

    IF m_factory IS NOT INITIAL.
      factory = m_factory.
      RETURN.
    ENDIF.

    factory = NEW zsd_sales_order_dp_ft( ).

  ENDMETHOD.

  METHOD set_factory.
    m_factory = factory.
  ENDMETHOD.

  METHOD zsd_sales_order_dp_ft_i~get_data_provider.

    DATA(temp_sales_order_dp) = NEW zsd_sales_order_dp( ).

    temp_sales_order_dp->m_sales_order_no = sales_order_no.

    sales_order_dp = temp_sales_order_dp.

  ENDMETHOD.

ENDCLASS.
