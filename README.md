# ZSD - Sales and Distribution
Install this code in package ZSD.

This package contains for now code about the Sales Order Business Object ZSD_SALES_ORDER_BO.

The functionality is limited to
- Creating a Sales Order PDF document
- Sending an Email with attached the Sales order PDF document

# Creating a Sales Order PDF document
Methods:
- ZSD_SALES_ORDER_BO_I~CREATE_DOCUMENT
- ZOPM_OUTP_PRINT_OUTPUT_I~EXECUTE

# Sending an Email with attached the Sales order PDF document
Methods:
- ZSD_SALES_ORDER_BO_I~CREATE_EMAIL
- ZOPM_OUTP_EXTERNAL_SEND_I~EXECUTE

# Prerequirements packages
- ZEXC - Exception : https://github.com/alwinvandeput/zexc_exception
- ZTXD - SAPscript texts : https://github.com/alwinvandeput/ztxd_sapscript_texts
  - Class with unit test: ZTXD_TEXT_OBJECT
  -Class with unit test:  ZTXD_TEXT_LABELS_OBJ
- ZADB - Adobe : https://github.com/alwinvandeput/zadb_adobe
  - Class with unit test: ZADB_ADOBE_DOCUMENT
- ZEML - Email : https://github.com/alwinvandeput/zeml_email
  - Class with unit test: ZEML_EXTENDED_EMAIL_BO
- ZBO  - Generic Business Object : https://github.com/alwinvandeput/zbo_generic_business_object
- ZOPM - Classic Output Management : https://github.com/alwinvandeput/zopm_classic_output_management

# Class with unit test
Class ZSD_SALES_ORDER_BO contains unit test class UNIT_TEST. First turn all the test off and than test them each by each.

