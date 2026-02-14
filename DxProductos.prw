#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "aarray.CH"
#Include "json.ch"
#INCLUDE "RESTFUL.CH"

WSRESTFUL dxproductos DESCRIPTION "Productos dx"

	WSDATA limit      AS INTEGER
	WSDATA offset     AS INTEGER
	WSDATA code  AS STRING
	WSMETHOD GET DESCRIPTION "Productos dx" WSSYNTAX "/dxproductos"

END WSRESTFUL

WSMETHOD GET WSRECEIVE limit, offset, code WSSERVICE dxproductos
	LOCAL aProds := {}
	local objProducto
	

	::SetContentType("application/json;charset=utf-8")

	OrdenConsul	:= GetNextAlias()
	
	cTipoProd :=	"%%" // filtro por tipo de producto
	cProdCode :="%%" // codigo de producto
	

	if !empty(::code)
		cProdCode := "% AND B1_COD = '"+ ::code +"' %"
	endif



	BeginSql Alias OrdenConsul
		select B1_COD as COD_PROD, 
		B1_DESC AS NOM_PROD,
		B1_UM AS UNIMED,
		Z15.Z15_DESCRI AS NOM_SUBCATEGO
		from SB1010 SB1
		LEFT JOIN Z15010 Z15 ON Z15.D_E_L_E_T_ =' ' AND SB1.B1_UPRINCA  = Z15.Z15_COD
		WHERE SB1.D_E_L_E_T_ =' ' 
		AND SB1.B1_UESTPRO !='2'
		AND SB1.B1_LOCPAD !='GG'
		AND SB1.B1_TIPO IN ('ME','SM','MP')
		
	EndSql

	DbSelectArea(OrdenConsul) // seleccionar area Area

	While !(OrdenConsul)->(Eof())

		objProducto := JsonObject():new()
		objProducto['COD_PROD']	:= (OrdenConsul)->COD_PROD
		objProducto['NOM_PROD']	:= ALLTRIM((OrdenConsul)->NOM_PROD)
		objProducto['UNIMED']	:= ALLTRIM((OrdenConsul)->UNIMED)
		objProducto['NOM_SUBCATEGO']	:= ALLTRIM((OrdenConsul)->NOM_SUBCATEGO)
		aadd(aProds,objProducto)
		(OrdenConsul)->(dbSkip())
	END

	cJson := FWJsonSerialize(aProds,.T.,.T.)

	cJson := EncodeUtf8(cJson)
	cJson := DecodeUTF8(cJson)

	::SetResponse(cJson)

Return .T.
