*&---------------------------------------------------------------------*
*& Report ZDBM_ORDERS_REPORTS
*&---------------------------------------------------------------------*
*& Made by: Yousef Waleed
*&---------------------------------------------------------------------*

REPORT zdbm_orders_reports.

TYPES: BEGIN OF ty_alv,
         vbeln TYPE vbak-vbeln,
         auart TYPE vbak-auart,
         audat TYPE vbak-audat,
         matnr TYPE vbap-matnr,
         maktx TYPE makt-maktx,
       END OF ty_alv.

DATA: t_alv_data TYPE STANDARD TABLE OF ty_alv,
      vbeln      TYPE vbak-vbeln,
      audat      TYPE vbak-audat.

*&---------------------------------------------------------------------*
*& Selection Screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK son WITH FRAME TITLE txt1.
  SELECT-OPTIONS: on_vbeln FOR vbeln,
                  od_audat FOR audat.
  PARAMETERS:     sd_auart TYPE vbak-auart.
SELECTION-SCREEN END OF BLOCK son.

INITIALIZATION.
  txt1 = 'Sales Order Report'.

START-OF-SELECTION.

  IF sd_auart IS INITIAL.
    SELECT a~vbeln, a~auart, a~audat, b~matnr, c~maktx
      FROM vbak AS a
      INNER JOIN vbap AS b ON a~vbeln = b~vbeln
      LEFT JOIN makt AS c ON b~matnr = c~matnr AND c~spras = @sy-langu
      INTO TABLE @t_alv_data
      WHERE a~vbeln IN @on_vbeln
        AND a~audat IN @od_audat.
  ELSE.
    SELECT a~vbeln, a~auart, a~audat, b~matnr, c~maktx
      FROM vbak AS a
      INNER JOIN vbap AS b ON a~vbeln = b~vbeln
      LEFT JOIN makt AS c ON b~matnr = c~matnr AND c~spras = @sy-langu
      INTO TABLE @t_alv_data
      WHERE a~vbeln IN @on_vbeln
        AND a~audat IN @od_audat
        AND a~auart = @sd_auart.
  ENDIF.

  IF t_alv_data IS INITIAL.
    MESSAGE 'No records found' TYPE 'I'.
  ELSE.
    PERFORM display_alv.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv.

  DATA: t_fieldcat TYPE slis_t_fieldcat_alv,
        w_fieldcat TYPE slis_fieldcat_alv.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'VBELN'.
  w_fieldcat-seltext_m = 'Order'.
  APPEND w_fieldcat TO t_fieldcat.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'AUART'.
  w_fieldcat-seltext_m = 'Sales Document Type'.
  APPEND w_fieldcat TO t_fieldcat.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'AUDAT'.
  w_fieldcat-seltext_m = 'Order Date'.
  APPEND w_fieldcat TO t_fieldcat.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'MATNR'.
  w_fieldcat-seltext_m = 'Material'.
  APPEND w_fieldcat TO t_fieldcat.

  CLEAR w_fieldcat.
  w_fieldcat-fieldname = 'MAKTX'.
  w_fieldcat-seltext_m = 'Description'.
  APPEND w_fieldcat TO t_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = t_fieldcat
    TABLES
      t_outtab           = t_alv_data
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.