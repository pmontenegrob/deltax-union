#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "aarray.CH"
#Include "json.ch"
#INCLUDE "RESTFUL.CH"

WSRESTFUL dxpedidos DESCRIPTION "Clientes Delta X"

	//WSDATA limit      AS INTEGER
	//WSDATA offset     AS INTEGER
	WSDATA cfecha  AS STRING
	WSMETHOD GET DESCRIPTION "Clientes Delta" WSSYNTAX "/dxpedidos"

END WSRESTFUL

WSMETHOD GET WSRECEIVE limit, offset, cfecha WSSERVICE dxpedidos
	LOCAL aClientes := {}
	local objClientes
	

	::SetContentType("application/json;charset=utf-8")

	OrdenConsul	:= GetNextAlias()
	
	//cTipoCli :=	"%%" // filtro por tipo de producto
	//cCliCode :="%%" // codigo de producto
	
	//fecha := "% AND A1_LOJA = '"+ ::cfecha +"' %" 
	if !empty(::cfecha)
		Femisao := "% AND SD2.D2_EMISSAO >='"+ ::cfecha +"' %"
	else
		Femisao := "% AND SD2.D2_EMISSAO >= CONVERT(VARCHAR(6), GETDATE(), 112) + '01' %"

	endif



	BeginSql Alias OrdenConsul
		
		SELECT 
		CASE SD2.D2_FILIAL
        WHEN '0100' THEN 'Beni'
        WHEN '0102' THEN 'Montero'
        WHEN '0105' THEN 'Santa Cruz'
        WHEN '0107' THEN 'Cochabamba'
        WHEN '0108' THEN 'La Paz'
        WHEN '0112' THEN 'San Ignacio'
        WHEN '0120' THEN 'San Jose'
        ELSE 'Sin Sucursal'
    	END AS SUCURSAL, 
		SD2.D2_LOCAL AS BODEGA,
		NNR.NNR_DESCRI AS BODEGA_DESC,
		NNR.NNR_ULAT AS BODEGA_LAT,
		NNR.NNR_ULON AS BODEGA_LON,
		SC5.C5_UTIPOEN AS TIPO_ENTREGA,
		CASE SC5.C5_UTIPOEN
        WHEN '1' THEN 'Ent.Rap'
        WHEN '2' THEN 'Ent.Sala'
        WHEN '4' THEN 'Desp.Local'
        WHEN '5' THEN 'Desp.Prov'
        WHEN '6' THEN 'Kardex'
        WHEN '7' THEN 'Deliv'
        WHEN '8' THEN 'ECOMMERCE'
        WHEN '9' THEN 'Recoge Cliente'
        WHEN '10' THEN 'Even.Ferias'
        WHEN '11' THEN 'Ent.Suc'
        WHEN '12' THEN 'Ent.EDV'
        ELSE 'Otro'
    	END AS TIPO_ENTREGA_DESC,
		CONCAT(SD2.D2_SERIE, '-', CAST(CAST(SD2.D2_DOC AS INT) AS VARCHAR)) AS NUMERO_GUIA,
		SD2.D2_EMISSAO AS FECHA,
		SF2.F2_HORA AS HORA ,
		SC5.C5_NUM AS PEDIDO ,
		SC5.C5_CLIENTE AS CODIGO_CLI ,
		SA1.A1_NREDUZ AS NOMBRE_CLI ,
		SA1.A1_UCELULA AS CONTACTO ,
		SA1.A1_END AS DIRECCION,
		SA1.A1_UCRMLAT AS LATITUD ,
		SA1.A1_UCRMLON AS LONGITUD,
		SA1.A1_EMAIL AS EMAIL_CONTACTO,
		SD2.D2_COD AS CODIGO_ITEM,
		SD2.D2_UDESC  AS NOMBRE_ITEM,
		SD2.D2_LOTECTL AS LOTE,
		SD2.D2_DTVALID AS VENCTO,
		SD2.D2_QUANT AS CANTIDAD,
		SA3.A3_NOME  AS NOMBRE_EDV,
		SA3.A3_TEL AS CELULAR_EDV,
		SA3.A3_EMAIL AS EMAIL_EDV
		FROM SD2010 SD2  
		left join SC5010 SC5 ON SC5.C5_NUM = SD2.D2_PEDIDO AND SC5.D_E_L_E_T_ =' ' AND SC5.C5_FILIAL = SD2.D2_FILIAL
		left join SF2010 SF2 ON SF2.F2_DOC  = SD2.D2_DOC  AND SF2.D_E_L_E_T_ =' ' AND SF2.F2_SERIE  = SD2.D2_SERIE 
		left join SA1010 SA1 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ =' '
		left join NNR010 NNR ON NNR.NNR_CODIGO = SD2.D2_LOCAL AND NNR.NNR_FILIAL =SD2.D2_FILIAL AND NNR.D_E_L_E_T_ =' '
		left join SA3010 SA3 ON SA3.A3_COD = SC5.C5_VEND1 AND SA3.D_E_L_E_T_=' '
		WHERE SD2.D_E_L_E_T_ =' ' and SD2.D2_ESPECIE  = 'NF'
		%Exp:Femisao%	
	EndSql
	DbSelectArea(OrdenConsul) // seleccionar area Area
	While !(OrdenConsul)->(Eof())
objClientes := JsonObject():new()
		objClientes['SUCURSAL']	:= ALLTRIM((OrdenConsul)->SUCURSAL)
		objClientes['BODEGA']	:= ALLTRIM((OrdenConsul)->BODEGA)
		objClientes['BODEGA_DESC']	:= ALLTRIM((OrdenConsul)->BODEGA_DESC)
		objClientes['BODEGA_LAT']	:= ALLTRIM((OrdenConsul)->BODEGA_LAT)
		objClientes['BODEGA_LON']	:= ALLTRIM((OrdenConsul)->BODEGA_LON)
		objClientes['TIPO_ENTREGA']	:= ALLTRIM((OrdenConsul)->TIPO_ENTREGA)
		objClientes['TIPO_ENTREGA_DESC']	:= ALLTRIM((OrdenConsul)->TIPO_ENTREGA_DESC)
		objClientes['NUMERO_GUIA']	:= ALLTRIM((OrdenConsul)->NUMERO_GUIA)
		objClientes['FECHA']	:= ALLTRIM((OrdenConsul)->FECHA)
		objClientes['HORA']	:= ALLTRIM((OrdenConsul)->HORA)
		objClientes['PEDIDO']	:= ALLTRIM((OrdenConsul)->PEDIDO)
		objClientes['CODIGO_CLI']	:= ALLTRIM((OrdenConsul)->CODIGO_CLI)
		objClientes['NOMBRE_CLI']	:= ALLTRIM((OrdenConsul)->NOMBRE_CLI)
		objClientes['CONTACTO']	:= ALLTRIM((OrdenConsul)->CONTACTO)
		objClientes['DIRECCION']	:= ALLTRIM((OrdenConsul)->DIRECCION)
		objClientes['LATITUD']	:= ALLTRIM((OrdenConsul)->LATITUD)
		objClientes['LONGITUD']	:= ALLTRIM((OrdenConsul)->LONGITUD)
		objClientes['EMAIL_CONTACTO']	:= ALLTRIM((OrdenConsul)->EMAIL_CONTACTO)
		objClientes['CODIGO_ITEM']	:= ALLTRIM((OrdenConsul)->CODIGO_ITEM)
		objClientes['NOMBRE_ITEM']	:= ALLTRIM((OrdenConsul)->NOMBRE_ITEM)
		objClientes['LOTE']	:= ALLTRIM((OrdenConsul)->LOTE)
		objClientes['VENCTO']	:= ALLTRIM((OrdenConsul)->VENCTO)
		objClientes['CANTIDAD']	:= (OrdenConsul)->CANTIDAD
		objClientes['NOMBRE_EDV']	:= ALLTRIM((OrdenConsul)->NOMBRE_EDV)
		objClientes['CELULAR_EDV']	:= ALLTRIM((OrdenConsul)->CELULAR_EDV)
		objClientes['EMAIL_EDV'] :=ALLTRIM((OrdenConsul)->EMAIL_EDV)
		objClientes['CONTACTO_NOTIFICACION'] := "69122029"
		aadd(aClientes,objClientes)
		(OrdenConsul)->(dbSkip())
	END

	cJson := FWJsonSerialize(aClientes,.T.,.T.)

	cJson := EncodeUtf8(cJson)
	cJson := DecodeUTF8(cJson)

	::SetResponse(cJson)

Return .T.
